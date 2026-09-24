#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="2dad6e54b"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

GATE_API="client/src/approvals/governanceEnvelopeGateApi.ts"
GATE_TEST="client/src/approvals/governanceEnvelopeGateApi.test.ts"
ENVELOPE_API="client/src/approvals/governanceEnvelopeApi.ts"
ENVELOPE_TEST="client/src/approvals/governanceEnvelopeApi.test.ts"
WORKSPACE="client/src/approvals/ApprovalsWorkspace.tsx"

for target in "$GATE_API" "$GATE_TEST" "$WORKSPACE"; do
  test -f "$target"
done

cat > "$GATE_API" << 'TS'
export type GovernanceEnvelopeGateInput = {
  gate_id: string;
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
};

export type GovernanceEnvelopeGateRecord = {
  envelope_gate_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  gate_status: string;
  gate_reason: string | null;
  gate_decision_timestamp: string | null;
  created_at: string;
};

export type GovernanceEnvelopeGateSuccess = {
  ok: true;
  envelope_gate: GovernanceEnvelopeGateRecord;
};

export async function postGovernanceEnvelopeGate(
  input: GovernanceEnvelopeGateInput,
): Promise<GovernanceEnvelopeGateSuccess> {
  const gate_id = input.gate_id.trim();
  const validation_result_id = input.validation_result_id.trim();
  const package_id = input.package_id.trim();
  const delegation_id = input.delegation_id.trim();

  if (!gate_id) {
    throw new Error("Envelope Gate id is required.");
  }

  if (!validation_result_id) {
    throw new Error("Validation result id is required.");
  }

  if (!package_id) {
    throw new Error("Package id is required.");
  }

  if (
    !Number.isInteger(input.package_version) ||
    input.package_version < 1
  ) {
    throw new Error("Package version must be a positive integer.");
  }

  if (!delegation_id) {
    throw new Error("Delegation id is required.");
  }

  const response = await fetch("/api/governance/envelope-gate", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify({
      envelope_gate_id: gate_id,
      validation_result_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
      gate_status: "OPEN",
      gate_reason: null,
      gate_decision_timestamp: new Date().toISOString(),
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | GovernanceEnvelopeGateSuccess
    | { error?: string; findings?: string[] }
    | null;

  if (!response.ok) {
    const finding =
      payload && "findings" in payload
        ? payload.findings?.[0]?.trim()
        : undefined;
    const error =
      payload && "error" in payload
        ? payload.error?.trim()
        : undefined;

    throw new Error(
      finding ||
        error ||
        `Governance Envelope Gate request failed with status ${response.status}.`,
    );
  }

  if (
    !payload ||
    !("ok" in payload) ||
    payload.ok !== true ||
    !("envelope_gate" in payload) ||
    !payload.envelope_gate?.envelope_gate_id?.trim()
  ) {
    throw new Error(
      "Governance Envelope Gate success response did not include the exact persisted Envelope Gate id.",
    );
  }

  return payload;
}
TS

cat > "$GATE_TEST" << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";

test("posts exact Validation lineage and returns exact persisted Gate id", async () => {
  const originalFetch = globalThis.fetch;
  let requestUrl = "";
  let requestInit: RequestInit | undefined;

  globalThis.fetch = (async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    requestUrl =
      typeof input === "string"
        ? input
        : input instanceof URL
          ? input.toString()
          : input.url;
    requestInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        envelope_gate: {
          envelope_gate_id: "gate-1",
          package_id: "package-1",
          package_version: 4,
          delegation_id: "delegation-1",
          validation_result_id: "validation-1",
          gate_status: "OPEN",
          gate_reason: null,
          gate_decision_timestamp: "2026-09-24T00:00:00.000Z",
          created_at: "2026-09-24T00:00:00.000Z",
        },
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  }) as typeof fetch;

  try {
    const result = await postGovernanceEnvelopeGate({
      gate_id: "gate-1",
      validation_result_id: "validation-1",
      package_id: "package-1",
      package_version: 4,
      delegation_id: "delegation-1",
    });

    assert.equal(requestUrl, "/api/governance/envelope-gate");
    assert.equal(requestInit?.method, "POST");

    const body = JSON.parse(String(requestInit?.body));

    assert.equal(body.envelope_gate_id, "gate-1");
    assert.equal(body.validation_result_id, "validation-1");
    assert.equal(body.package_id, "package-1");
    assert.equal(body.package_version, 4);
    assert.equal(body.delegation_id, "delegation-1");
    assert.equal(body.gate_status, "OPEN");
    assert.equal(body.gate_reason, null);
    assert.equal(
      typeof body.gate_decision_timestamp,
      "string",
    );

    assert.equal(
      result.envelope_gate.envelope_gate_id,
      "gate-1",
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("fails closed when successful Gate response omits exact persisted Gate id", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: {
        "content-type": "application/json",
      },
    })) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: "validation-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /exact persisted Envelope Gate id/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects missing Validation lineage before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = (async () => {
    fetchCalled = true;
    throw new Error("fetch must not be called");
  }) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: " ",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /Validation result id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces Envelope Gate route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(
      JSON.stringify({
        findings: [
          "Validation result is not eligible for Envelope Gate.",
        ],
      }),
      {
        status: 409,
        headers: {
          "content-type": "application/json",
        },
      },
    )) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelopeGate({
        gate_id: "gate-1",
        validation_result_id: "validation-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      }),
      /Validation result is not eligible for Envelope Gate/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

cat > "$ENVELOPE_API" << 'TS'
export type GovernanceEnvelopeInput = {
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
};

export type GovernanceEnvelopeSuccess = {
  ok: true;
  envelope: {
    envelope: {
      envelope_id: string;
      package_id: string;
      package_version: number;
      delegation_id: string;
      validation_result_id: string;
      envelope_gate_id: string;
      validation_status: string;
      lifecycle_state: string;
      created_at: string;
    };
  };
};

export async function postGovernanceEnvelope(
  input: GovernanceEnvelopeInput,
): Promise<GovernanceEnvelopeSuccess> {
  const envelope_id = input.envelope_id.trim();
  const package_id = input.package_id.trim();
  const delegation_id = input.delegation_id.trim();
  const validation_result_id = input.validation_result_id.trim();
  const envelope_gate_id = input.envelope_gate_id.trim();

  if (!envelope_id) {
    throw new Error("Envelope id is required.");
  }

  if (!package_id) {
    throw new Error("Package id is required.");
  }

  if (
    !Number.isInteger(input.package_version) ||
    input.package_version < 1
  ) {
    throw new Error("Package version must be a positive integer.");
  }

  if (!delegation_id) {
    throw new Error("Delegation id is required.");
  }

  if (!validation_result_id) {
    throw new Error("Validation result id is required.");
  }

  if (!envelope_gate_id) {
    throw new Error("Envelope Gate id is required.");
  }

  const response = await fetch("/api/governance/envelope", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify({
      envelope_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      lifecycle_state: "ENVELOPE_CREATED",
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | GovernanceEnvelopeSuccess
    | { error?: string; findings?: string[] }
    | null;

  if (!response.ok) {
    const finding =
      payload && "findings" in payload
        ? payload.findings?.[0]?.trim()
        : undefined;
    const error =
      payload && "error" in payload
        ? payload.error?.trim()
        : undefined;

    throw new Error(
      finding ||
        error ||
        `Governance Envelope request failed with status ${response.status}.`,
    );
  }

  if (
    !payload ||
    !("ok" in payload) ||
    payload.ok !== true ||
    !("envelope" in payload)
  ) {
    throw new Error(
      "Governance Envelope success response was incomplete.",
    );
  }

  return payload;
}
TS

cat > "$ENVELOPE_TEST" << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import { postGovernanceEnvelope } from "./governanceEnvelopeApi";

test("posts only exact retained lineage to existing Envelope route", async () => {
  const originalFetch = globalThis.fetch;
  let requestUrl = "";
  let requestInit: RequestInit | undefined;

  globalThis.fetch = (async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    requestUrl =
      typeof input === "string"
        ? input
        : input instanceof URL
          ? input.toString()
          : input.url;
    requestInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        envelope: {
          envelope: {
            envelope_id: "envelope-1",
            package_id: "package-1",
            package_version: 4,
            delegation_id: "delegation-1",
            validation_result_id: "validation-1",
            envelope_gate_id: "gate-1",
            validation_status: "VALIDATION_PASSED",
            lifecycle_state: "ENVELOPE_CREATED",
            created_at: "2026-09-24T00:01:00.000Z",
          },
        },
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  }) as typeof fetch;

  try {
    await postGovernanceEnvelope({
      envelope_id: "envelope-1",
      package_id: "package-1",
      package_version: 4,
      delegation_id: "delegation-1",
      validation_result_id: "validation-1",
      envelope_gate_id: "gate-1",
    });

    assert.equal(requestUrl, "/api/governance/envelope");
    assert.equal(requestInit?.method, "POST");

    assert.deepEqual(
      JSON.parse(String(requestInit?.body)),
      {
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: "gate-1",
        lifecycle_state: "ENVELOPE_CREATED",
      },
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects missing exact Gate lineage before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = (async () => {
    fetchCalled = true;
    throw new Error("fetch must not be called");
  }) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelope({
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: " ",
      }),
      /Envelope Gate id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces Envelope route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = (async () =>
    new Response(
      JSON.stringify({
        findings: [
          "Governance Envelope route failed closed because the production Envelope consumer rejected the request.",
        ],
      }),
      {
        status: 409,
        headers: {
          "content-type": "application/json",
        },
      },
    )) as typeof fetch;

  try {
    await assert.rejects(
      postGovernanceEnvelope({
        envelope_id: "envelope-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
        validation_result_id: "validation-1",
        envelope_gate_id: "gate-1",
      }),
      /production Envelope consumer rejected the request/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

python3 << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

import_anchor = 'import { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";'
if import_anchor not in text:
    raise SystemExit("Envelope Gate import anchor not found.")

text = text.replace(
    import_anchor,
    import_anchor + '\nimport { postGovernanceEnvelope } from "./governanceEnvelopeApi";',
    1,
)

state_anchor = '''  const [envelopeGateComplete, setEnvelopeGateComplete] = useState(false);
'''
if state_anchor not in text:
    raise SystemExit("Envelope Gate state anchor not found.")

text = text.replace(
    state_anchor,
    state_anchor
    + '''  const [envelopeGateId, setEnvelopeGateId] = useState<string | null>(null);
  const [creatingEnvelope, setCreatingEnvelope] = useState(false);
  const [envelopeComplete, setEnvelopeComplete] = useState(false);
  const [envelopeError, setEnvelopeError] = useState<string | null>(null);
''',
    1,
)

old_gate_call = '''      await postGovernanceEnvelopeGate({
        gate_id: crypto.randomUUID(),
        validation_result_id: validationResultId,
'''
if old_gate_call not in text:
    raise SystemExit("Existing Gate call anchor not found.")

new_gate_call = '''      const gateId = crypto.randomUUID();
      const gateResult = await postGovernanceEnvelopeGate({
        gate_id: gateId,
        validation_result_id: validationResultId,
'''

text = text.replace(old_gate_call, new_gate_call, 1)

success_anchor = '''      setEnvelopeGateComplete(true);
'''
if success_anchor not in text:
    raise SystemExit("Envelope Gate success anchor not found.")

text = text.replace(
    success_anchor,
    '''      setEnvelopeGateId(
        gateResult.envelope_gate.envelope_gate_id,
      );
      setEnvelopeGateComplete(true);
''',
    1,
)

handler_anchor = '''  async function handleCreateEnvelopeGate(): Promise<void> {
'''
handler_index = text.find(handler_anchor)
if handler_index == -1:
    raise SystemExit("Gate handler anchor not found.")

next_function_index = text.find(
    "\n  async function ",
    handler_index + len(handler_anchor),
)
if next_function_index == -1:
    raise SystemExit("Next function boundary after Gate handler not found.")

envelope_handler = '''
  async function handleCreateEnvelope(): Promise<void> {
    if (
      creatingEnvelope ||
      envelopeComplete ||
      !envelopeGateComplete ||
      !envelopeGateId ||
      !validationResultId ||
      !selectedRequest?.package_id ||
      !selectedRequest?.package_version ||
      !selectedRequest?.delegation?.delegation_id
    ) {
      return;
    }

    setCreatingEnvelope(true);
    setEnvelopeError(null);

    try {
      await postGovernanceEnvelope({
        envelope_id: crypto.randomUUID(),
        package_id: selectedRequest.package_id,
        package_version: selectedRequest.package_version,
        delegation_id: selectedRequest.delegation.delegation_id,
        validation_result_id: validationResultId,
        envelope_gate_id: envelopeGateId,
      });

      setEnvelopeComplete(true);
    } catch (error) {
      setEnvelopeError(
        error instanceof Error
          ? error.message
          : "Governance Envelope could not be created.",
      );
    } finally {
      setCreatingEnvelope(false);
    }
  }

'''

text = (
    text[:next_function_index]
    + envelope_handler
    + text[next_function_index:]
)

ui_anchor = '''          {envelopeGateError ? (
'''
if ui_anchor not in text:
    raise SystemExit("Envelope Gate error UI anchor not found.")

envelope_ui = '''          {envelopeGateComplete && envelopeGateId ? (
            <section
              className="executive-action-card"
              aria-labelledby="executive-envelope-action-title"
            >
              <div>
                <h3 id="executive-envelope-action-title">
                  Envelope
                </h3>
                <p>
                  Explicitly creates the Envelope for this exact passed
                  Validation and recorded Envelope Gate lineage. It does not
                  authorize lifecycle transition, routing, assignment,
                  scheduling, orchestration, or execution.
                </p>
              </div>
              <button
                type="button"
                disabled={creatingEnvelope || envelopeComplete}
                onClick={() => void handleCreateEnvelope()}
              >
                {envelopeComplete
                  ? "Envelope created"
                  : creatingEnvelope
                    ? "Creating Envelope..."
                    : "Create Envelope"}
              </button>
            </section>
          ) : null}

          {envelopeError ? (
            <p role="alert" className="executive-action-error">
              {envelopeError}
            </p>
          ) : null}

'''

text = text.replace(ui_anchor, envelope_ui + ui_anchor, 1)

path.write_text(text)
PY

git diff --check -- \
  "$GATE_API" \
  "$GATE_TEST" \
  "$ENVELOPE_API" \
  "$ENVELOPE_TEST" \
  "$WORKSPACE"

npm run check

./node_modules/.bin/tsx --test \
  "$GATE_TEST" \
  "$ENVELOPE_TEST"

git add -- \
  "$GATE_API" \
  "$GATE_TEST" \
  "$ENVELOPE_API" \
  "$ENVELOPE_TEST" \
  "$WORKSPACE"

test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "5"

for target in \
  "$GATE_API" \
  "$GATE_TEST" \
  "$ENVELOPE_API" \
  "$ENVELOPE_TEST" \
  "$WORKSPACE"
do
  git diff --cached --name-only | grep -Fxq "$target"
done

git commit -m "Expose explicit operator Envelope action"
git push origin "$BRANCH"
