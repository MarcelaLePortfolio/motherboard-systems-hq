#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="cf9d00f27"

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

test -z "$(git status --porcelain -- "$UI")"
test ! -e "$API"
test ! -e "$TEST"

restore_targets() {
  git restore --source="$EXPECTED_HEAD" --staged --worktree -- "$UI" 2>/dev/null || true
  rm -f -- "$API" "$TEST"
}

on_error() {
  code=$?
  printf '\nATTEMPT_1=FAILED\n'
  printf 'FAILURE_EXIT_CODE=%s\n' "$code"
  restore_targets
  exit "$code"
}

trap on_error ERR

printf '\n====================================================\n'
printf ' EXPLICIT OPERATOR ENVELOPE GATE — ATTEMPT 1\n'
printf '====================================================\n\n'

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "ATTEMPT=1"
echo "TARGET_COUNT=3"
echo "LIVE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "NEW_AUTHORITY=NO"

cat > "$API" << 'TS'
export type GovernanceEnvelopeGateIdentity = {
  envelope_gate_id: string;
  validation_result_id: string;
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceEnvelopeGateResult = {
  ok: boolean;
  envelope_gate?: unknown;
  findings?: string[];
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required Envelope Gate field: ${field}`);
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error("Missing required Envelope Gate field: package_version");
  }

  return Number(value);
}

export async function postGovernanceEnvelopeGate(
  identity: GovernanceEnvelopeGateIdentity,
  fetchImpl: typeof fetch = fetch,
): Promise<GovernanceEnvelopeGateResult> {
  const request = {
    envelope_gate_id: requireText(
      identity.envelope_gate_id,
      "envelope_gate_id",
    ),
    validation_result_id: requireText(
      identity.validation_result_id,
      "validation_result_id",
    ),
    delegation_id: requireText(identity.delegation_id, "delegation_id"),
    package_id: requireText(identity.package_id, "package_id"),
    package_version: requirePackageVersion(identity.package_version),
  };

  const response = await fetchImpl("/api/governance/envelope-gate", {
    method: "POST",
    headers: {
      "content-type": "application/json",
    },
    body: JSON.stringify(request),
  });

  const payload = (await response.json()) as GovernanceEnvelopeGateResult;

  if (!response.ok || payload.ok !== true) {
    const findings =
      Array.isArray(payload.findings) && payload.findings.length > 0
        ? payload.findings.join("; ")
        : `Envelope Gate request failed with HTTP ${response.status}`;

    throw new Error(findings);
  }

  return payload;
}
TS

cat > "$TEST" << 'TS'
import test from "node:test";
import assert from "node:assert/strict";

import {
  postGovernanceEnvelopeGate,
  type GovernanceEnvelopeGateIdentity,
} from "./governanceEnvelopeGateApi";

const identity: GovernanceEnvelopeGateIdentity = {
  envelope_gate_id: "gate-operator-1",
  validation_result_id: "validation-operator-1",
  delegation_id: "delegation-operator-1",
  package_id: "package-operator-1",
  package_version: 7,
};

test("posts exact successful Validation lineage to existing Envelope Gate route", async () => {
  let capturedUrl = "";
  let capturedInit: RequestInit | undefined;

  const fetchImpl: typeof fetch = async (input, init) => {
    capturedUrl = String(input);
    capturedInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        envelope_gate: {
          envelope_gate_id: identity.envelope_gate_id,
        },
        findings: [],
      }),
      {
        status: 200,
        headers: {
          "content-type": "application/json",
        },
      },
    );
  };

  const result = await postGovernanceEnvelopeGate(identity, fetchImpl);

  assert.equal(result.ok, true);
  assert.equal(capturedUrl, "/api/governance/envelope-gate");
  assert.equal(capturedInit?.method, "POST");

  assert.deepEqual(JSON.parse(String(capturedInit?.body)), identity);
});

test("rejects invalid Envelope Gate identity before fetch", async () => {
  let fetchCalls = 0;

  const fetchImpl: typeof fetch = async () => {
    fetchCalls += 1;
    throw new Error("fetch must not run");
  };

  await assert.rejects(
    () =>
      postGovernanceEnvelopeGate(
        {
          ...identity,
          validation_result_id: "",
        },
        fetchImpl,
      ),
    /validation_result_id/,
  );

  assert.equal(fetchCalls, 0);
});

test("surfaces governance Envelope Gate route failure", async () => {
  const fetchImpl: typeof fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        findings: ["Validation result is not eligible for Envelope Gate"],
      }),
      {
        status: 409,
        headers: {
          "content-type": "application/json",
        },
      },
    );

  await assert.rejects(
    () => postGovernanceEnvelopeGate(identity, fetchImpl),
    /Validation result is not eligible for Envelope Gate/,
  );
});
TS

python3 - <<'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

validation_import = 'from "./governanceValidationApi"'
if validation_import not in text:
    raise SystemExit("governance Validation API import anchor not found")

lines = text.splitlines()
import_index = next(
    i for i, line in enumerate(lines)
    if validation_import in line
)

statement_start = import_index
while statement_start > 0 and not lines[statement_start].lstrip().startswith("import "):
    statement_start -= 1

statement_end = import_index
while statement_end < len(lines) and ";" not in lines[statement_end]:
    statement_end += 1

lines[statement_end + 1:statement_end + 1] = [
    'import { postGovernanceEnvelopeGate } from "./governanceEnvelopeGateApi";'
]
text = "\n".join(lines) + "\n"

validation_id_candidates = [
    "validation_result_id",
    "validationResultId",
]

if not any(candidate in text for candidate in validation_id_candidates):
    raise SystemExit("successful Validation identity anchor not found")

state_anchor_candidates = [
    "const [validation",
    "const [feedback",
]

state_pos = None
for candidate in state_anchor_candidates:
    pos = text.find(candidate)
    if pos >= 0:
        state_pos = pos
        break

if state_pos is None:
    raise SystemExit("ApprovalsWorkspace state anchor not found")

line_end = text.find("\n", state_pos)
if line_end < 0:
    raise SystemExit("state line end not found")

state_block = '''
  const [successfulValidationIdentity, setSuccessfulValidationIdentity] =
    useState<{
      validation_result_id: string;
      delegation_id: string;
      package_id: string;
      package_version: number;
    } | null>(null);
  const [envelopeGatePending, setEnvelopeGatePending] = useState(false);
  const [envelopeGateError, setEnvelopeGateError] = useState<string | null>(null);
  const [envelopeGateCreated, setEnvelopeGateCreated] = useState(false);
'''

text = text[:line_end + 1] + state_block + text[line_end + 1:]

validation_call = "postGovernanceValidation("
call_pos = text.find(validation_call)
if call_pos < 0:
    raise SystemExit("postGovernanceValidation call not found")

await_pos = text.rfind("await ", 0, call_pos + len(validation_call))
if await_pos < 0:
    raise SystemExit("await Validation call anchor not found")

statement_end = text.find(";", call_pos)
if statement_end < 0:
    raise SystemExit("Validation call statement end not found")

validation_statement = text[await_pos:statement_end + 1]

import re

id_match = re.search(
    r'validation_result_id\s*:\s*([A-Za-z_$][A-Za-z0-9_$]*)',
    validation_statement,
)
delegation_match = re.search(
    r'delegation_id\s*:\s*([A-Za-z_$][A-Za-z0-9_$.\[\]"\'-]*)',
    validation_statement,
)
package_match = re.search(
    r'package_id\s*:\s*([A-Za-z_$][A-Za-z0-9_$.\[\]"\'-]*)',
    validation_statement,
)
version_match = re.search(
    r'package_version\s*:\s*([A-Za-z_$][A-Za-z0-9_$.\[\]"\'-]*)',
    validation_statement,
)

if not all([id_match, delegation_match, package_match, version_match]):
    raise SystemExit("exact successful Validation identity expressions not found")

validation_id = id_match.group(1)
delegation_id = delegation_match.group(1)
package_id = package_match.group(1)
package_version = version_match.group(1)

success_insert = f'''
    setSuccessfulValidationIdentity({{
      validation_result_id: {validation_id},
      delegation_id: {delegation_id},
      package_id: {package_id},
      package_version: {package_version},
    }});
    setEnvelopeGateCreated(false);
    setEnvelopeGateError(null);
'''

text = text[:statement_end + 1] + success_insert + text[statement_end + 1:]

component_return = text.find("return (")
if component_return < 0:
    raise SystemExit("component return anchor not found")

handler = '''
  const handleCreateEnvelopeGate = async () => {
    if (!successfulValidationIdentity || envelopeGatePending) {
      return;
    }

    setEnvelopeGatePending(true);
    setEnvelopeGateError(null);

    try {
      await postGovernanceEnvelopeGate({
        envelope_gate_id: `envelope-gate-${crypto.randomUUID()}`,
        ...successfulValidationIdentity,
      });
      setEnvelopeGateCreated(true);
    } catch (error) {
      setEnvelopeGateError(
        error instanceof Error ? error.message : "Envelope Gate request failed",
      );
    } finally {
      setEnvelopeGatePending(false);
    }
  };

'''

text = text[:component_return] + handler + text[component_return:]

validate_button_candidates = [
    ">Validate<",
    "Validate package",
    "Run Validation",
]

button_pos = None
for candidate in validate_button_candidates:
    pos = text.find(candidate)
    if pos >= 0:
        button_pos = pos
        break

if button_pos is None:
    raise SystemExit("Validate button anchor not found")

closing_button = text.find("</button>", button_pos)
if closing_button < 0:
    raise SystemExit("Validate button closing tag not found")

closing_button += len("</button>")

gate_ui = '''
              {successfulValidationIdentity ? (
                <div>
                  <button
                    type="button"
                    onClick={handleCreateEnvelopeGate}
                    disabled={envelopeGatePending || envelopeGateCreated}
                  >
                    {envelopeGateCreated
                      ? "Envelope Gate created"
                      : envelopeGatePending
                        ? "Creating Envelope Gate…"
                        : "Create Envelope Gate"}
                  </button>
                  {envelopeGateError ? (
                    <p role="alert">{envelopeGateError}</p>
                  ) : null}
                </div>
              ) : null}
'''

text = text[:closing_button] + gate_ui + text[closing_button:]

path.write_text(text)
PY

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check -- "${TARGETS[@]}"

printf '\n=== GATE 2: ROOT TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: ENVELOPE GATE CLIENT TESTS ===\n'
./node_modules/.bin/tsx --test "$TEST"

printf '\n=== GATE 4: EXISTING VALIDATION CLIENT TESTS ===\n'
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

printf '\n=== ATTEMPT 1 RESULT ===\n'
echo "EXPLICIT_OPERATOR_ENVELOPE_GATE_ACTION=IMPLEMENTED"
echo "VALIDATION_AND_GATE_ACTIONS_SEPARATE=YES"
echo "SUCCESSFUL_VALIDATION_LINEAGE_RETAINED=YES"
echo "GATE_ACTION_REQUIRES_EXPLICIT_OPERATOR_CLICK=YES"
echo "AUTOMATIC_VALIDATION_TO_GATE_TRANSITION=NO"
echo "SERVER_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "SCHEMA_CHANGE=NONE"
echo "LIVE_GATE_INVOCATION=NONE"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NONE"
echo "AUTOMATIC_ENVELOPE_CREATION=NONE"
echo "EXECUTION_AUTHORITY=NONE"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"
echo "IMPLEMENTATION_HEAD=$(git rev-parse --short=9 HEAD)"
