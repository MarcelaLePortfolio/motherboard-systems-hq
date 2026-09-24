#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="c5c8f4784"

UI="client/src/approvals/ApprovalsWorkspace.tsx"
API="client/src/approvals/governanceEnvelopeGateApi.ts"
TEST="client/src/approvals/governanceEnvelopeGateApi.test.ts"

TARGETS=(
  "$UI"
  "$API"
  "$TEST"
)

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE — ATTEMPT 2\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "ATTEMPT=2"
echo "PREVIOUS_FAILURE=GUESSED_POST_GOVERNANCE_VALIDATION_SYMBOL"
echo "ACTUAL_VALIDATION_FUNCTION=handleValidate"
echo "ACTUAL_VALIDATION_API=submitGovernanceValidation"
echo "TARGET_COUNT=3"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== TARGET BASELINE GUARD ===\n'

test -z "$(git status --porcelain -- "$UI")"
test ! -e "$API"
test ! -e "$TEST"

grep -Fq \
  'import { submitGovernanceValidation } from "./governanceValidationApi";' \
  "$UI"

grep -Fq \
  'async function handleValidate(): Promise<void> {' \
  "$UI"

grep -Fq \
  'await submitGovernanceValidation({' \
  "$UI"

grep -Fq \
  'validation_result_id: crypto.randomUUID(),' \
  "$UI"

grep -Fq \
  'setValidationComplete(true);' \
  "$UI"

echo "TARGET_BASELINE_GUARD=PASS"

trap 'rc=$?; printf "\nATTEMPT_2=FAILED\nFAILURE_EXIT_CODE=%s\n" "$rc"; git restore -- "$UI" 2>/dev/null || true; rm -f "$API" "$TEST"; exit "$rc"' ERR

cat > "$API" << 'API_EOF'
export type GovernanceEnvelopeGateInput = {
  gate_id: string;
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
};

export async function postGovernanceEnvelopeGate(
  input: GovernanceEnvelopeGateInput,
): Promise<unknown> {
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
      gate_id,
      validation_result_id,
      package_id,
      package_version: input.package_version,
      delegation_id,
    }),
  });

  const payload = (await response.json().catch(() => null)) as
    | { error?: string; findings?: string[] }
    | null;

  if (!response.ok) {
    const finding = payload?.findings?.[0]?.trim();
    const error = payload?.error?.trim();

    throw new Error(
      finding ||
        error ||
        `Governance Envelope Gate request failed with status ${response.status}.`,
    );
  }

  return payload;
}
API_EOF

cat > "$TEST" << 'TEST_EOF'
import assert from "node:assert/strict";
import test from "node:test";

import { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";

test("posts exact Validation lineage to existing Envelope Gate route", async () => {
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

    return new Response(JSON.stringify({ ok: true }), {
      status: 200,
      headers: {
        "content-type": "application/json",
      },
    });
  }) as typeof fetch;

  try {
    await postGovernanceEnvelopeGate({
      gate_id: "gate-1",
      validation_result_id: "validation-1",
      package_id: "package-1",
      package_version: 4,
      delegation_id: "delegation-1",
    });

    assert.equal(requestUrl, "/api/governance/envelope-gate");
    assert.equal(requestInit?.method, "POST");

    assert.deepEqual(
      JSON.parse(String(requestInit?.body)),
      {
        gate_id: "gate-1",
        validation_result_id: "validation-1",
        package_id: "package-1",
        package_version: 4,
        delegation_id: "delegation-1",
      },
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
        findings: ["Validation result is not eligible for Envelope Gate."],
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
TEST_EOF

python3 - "$UI" << 'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

import_anchor = 'import { submitGovernanceValidation } from "./governanceValidationApi";'
import_replacement = import_anchor + '\nimport { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";'

if text.count(import_anchor) != 1:
    raise SystemExit("Validation import anchor count is not exactly one")

text = text.replace(import_anchor, import_replacement, 1)

state_anchor = '''  const [validationComplete, setValidationComplete] = useState(false);
'''

state_replacement = '''  const [validationComplete, setValidationComplete] = useState(false);
  const [validationResultId, setValidationResultId] =
    useState<string | null>(null);
  const [creatingEnvelopeGate, setCreatingEnvelopeGate] = useState(false);
  const [envelopeGateComplete, setEnvelopeGateComplete] = useState(false);
  const [envelopeGateError, setEnvelopeGateError] =
    useState<string | null>(null);
'''

if text.count(state_anchor) != 1:
    raise SystemExit("Validation state anchor count is not exactly one")

text = text.replace(state_anchor, state_replacement, 1)

validation_call_anchor = '''    try {
      await submitGovernanceValidation({
        validation_result_id: crypto.randomUUID(),
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        delegation_id: pkg.delegation.delegation_id,
        validation_status: validationStatus.trim(),
      });

      setValidationComplete(true);
'''

validation_call_replacement = '''    try {
      const validationResultId = crypto.randomUUID();

      await submitGovernanceValidation({
        validation_result_id: validationResultId,
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        delegation_id: pkg.delegation.delegation_id,
        validation_status: validationStatus.trim(),
      });

      setValidationResultId(validationResultId);
      setValidationComplete(true);
'''

if text.count(validation_call_anchor) != 1:
    raise SystemExit("Exact Validation call anchor count is not exactly one")

text = text.replace(
    validation_call_anchor,
    validation_call_replacement,
    1,
)

delegate_anchor = '''  async function handleDelegate(): Promise<void> {
'''

gate_handler = '''  async function handleCreateEnvelopeGate(): Promise<void> {
    if (
      creatingEnvelopeGate ||
      envelopeGateComplete ||
      !validationComplete ||
      !validationResultId ||
      pkg.delegation.state !== "delegated"
    ) {
      return;
    }

    setCreatingEnvelopeGate(true);
    setEnvelopeGateError(null);

    try {
      await postGovernanceEnvelopeGate({
        gate_id: crypto.randomUUID(),
        validation_result_id: validationResultId,
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        delegation_id: pkg.delegation.delegation_id,
      });

      setEnvelopeGateComplete(true);
    } catch (error) {
      setEnvelopeGateError(
        error instanceof Error
          ? error.message
          : "Governance Envelope Gate could not be recorded.",
      );
    } finally {
      setCreatingEnvelopeGate(false);
    }
  }

'''

if text.count(delegate_anchor) != 1:
    raise SystemExit("Delegate handler anchor count is not exactly one")

text = text.replace(delegate_anchor, gate_handler + delegate_anchor, 1)

validation_error_anchor = '''          {validationError ? (
'''

gate_ui = '''          {validationComplete && validationResultId ? (
            <section
              className="executive-validation-action"
              aria-labelledby="executive-envelope-gate-action-title"
            >
              <div>
                <h3 id="executive-envelope-gate-action-title">
                  Envelope Gate
                </h3>
                <p>
                  Explicitly records the Envelope Gate for this exact passed
                  Validation lineage only. It does not create an Envelope or
                  authorize execution.
                </p>
              </div>

              <button
                type="button"
                disabled={creatingEnvelopeGate || envelopeGateComplete}
                onClick={() => void handleCreateEnvelopeGate()}
              >
                {envelopeGateComplete
                  ? "Envelope Gate recorded"
                  : creatingEnvelopeGate
                    ? "Recording Envelope Gate..."
                    : "Record Envelope Gate"}
              </button>
            </section>
          ) : null}

          {envelopeGateError ? (
            <p role="alert" className="executive-validation-error">
              {envelopeGateError}
            </p>
          ) : null}

'''

if text.count(validation_error_anchor) != 1:
    raise SystemExit("Validation error UI anchor count is not exactly one")

text = text.replace(
    validation_error_anchor,
    gate_ui + validation_error_anchor,
    1,
)

path.write_text(text)
PY

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check -- "${TARGETS[@]}"

printf '\n=== GATE 2: ROOT TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: ENVELOPE GATE ADAPTER TESTS ===\n'
./node_modules/.bin/tsx --test "$TEST"

printf '\n=== GATE 4: EXISTING VALIDATION ADAPTER TESTS ===\n'
./node_modules/.bin/tsx --test \
  client/src/approvals/governanceValidationApi.test.ts

printf '\n=== GATE 5: CLIENT BUILD ===\n'
(
  cd client
  npm run build
)

printf '\n=== AUTHORIZED TARGET STATUS ===\n'
git status --short -- "${TARGETS[@]}"

git add -- "${TARGETS[@]}"

test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "3"

for f in "${TARGETS[@]}"; do
  git diff --cached --name-only | grep -Fxq "$f"
done

git commit -m "Expose explicit operator envelope gate action"
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

trap - ERR

printf '\n=== ATTEMPT 2 RESULT ===\n'
echo "EXPLICIT_OPERATOR_ENVELOPE_GATE_ACTION=IMPLEMENTED"
echo "EXACT_SUCCESSFUL_VALIDATION_RESULT_ID_RETAINED=YES"
echo "VALIDATION_AND_GATE_ACTIONS_SEPARATE=YES"
echo "GATE_ACTION_REQUIRES_EXPLICIT_OPERATOR_CLICK=YES"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "SERVER_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "SCHEMA_CHANGE=NONE"
echo "LIVE_GATE_INVOCATION=NONE"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NONE"
echo "EXECUTION_AUTHORITY=NONE"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"
echo "IMPLEMENTATION_HEAD=$(git rev-parse --short=9 HEAD)"
