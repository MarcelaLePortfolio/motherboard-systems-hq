#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="07bf117e4"

UI="client/src/approvals/ApprovalsWorkspace.tsx"
API="client/src/approvals/governanceValidationApi.ts"
TEST="client/src/approvals/governanceValidationApi.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

test -z "$(git diff -- "$UI")"
test ! -e "$API"
test ! -e "$TEST"

restore_targets() {
  git restore -- "$UI" 2>/dev/null || true
  rm -f -- "$API" "$TEST"
}

trap 'echo "ATTEMPT_2=FAILED"; restore_targets' ERR

cat > "$API" << 'TS'
export type GovernanceValidationRequest = {
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_status: string;
  governance_findings?: string | null;
  operational_requirements?: string | null;
  capability_requirements?: string | null;
  escalations?: string | null;
};

export type GovernanceValidationResponse = {
  ok: boolean;
  findings?: string[];
  [key: string]: unknown;
};

function requireText(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`${field} is required.`);
  }
  return normalized;
}

export async function submitGovernanceValidation(
  input: GovernanceValidationRequest,
  fetchImpl: typeof fetch = fetch,
): Promise<GovernanceValidationResponse> {
  const request = {
    ...input,
    validation_result_id: requireText(
      input.validation_result_id,
      "validation_result_id",
    ),
    package_id: requireText(input.package_id, "package_id"),
    delegation_id: requireText(input.delegation_id, "delegation_id"),
    validation_status: requireText(input.validation_status, "validation_status"),
  };

  if (!Number.isInteger(request.package_version) || request.package_version <= 0) {
    throw new Error("package_version must be a positive integer.");
  }

  const response = await fetchImpl("/api/governance/validation", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(request),
  });

  const result =
    (await response.json()) as GovernanceValidationResponse;

  if (!response.ok || !result.ok) {
    throw new Error(
      result.findings?.[0] ?? "Governance Validation failed closed.",
    );
  }

  return result;
}
TS

cat > "$TEST" << 'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  submitGovernanceValidation,
} from "./governanceValidationApi";

const validInput = {
  validation_result_id: "validation-result-test",
  package_id: "pkg-test",
  package_version: 7,
  delegation_id: "delegation-test",
  validation_status: "VALIDATION_PASSED",
};

test("posts exact Validation identity to existing governance Validation route", async () => {
  const originalFetch = globalThis.fetch;
  let capturedUrl: string | URL | Request | null = null;
  let capturedInit: RequestInit | undefined;

  globalThis.fetch = async (
    input: string | URL | Request,
    init?: RequestInit,
  ) => {
    capturedUrl = input;
    capturedInit = init;

    return new Response(
      JSON.stringify({
        ok: true,
        findings: [],
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  };

  try {
    await submitGovernanceValidation(validInput);

    assert.equal(capturedUrl, "/api/governance/validation");
    assert.equal(capturedInit?.method, "POST");
    assert.deepEqual(
      JSON.parse(String(capturedInit?.body)),
      validInput,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("rejects invalid Validation identity before fetch", async () => {
  const originalFetch = globalThis.fetch;
  let fetchCalled = false;

  globalThis.fetch = async () => {
    fetchCalled = true;
    throw new Error("fetch should not be called");
  };

  try {
    await assert.rejects(
      submitGovernanceValidation({
        ...validInput,
        delegation_id: "",
      }),
      /delegation_id is required/,
    );

    assert.equal(fetchCalled, false);
  } finally {
    globalThis.fetch = originalFetch;
  }
});

test("surfaces governance Validation route failure", async () => {
  const originalFetch = globalThis.fetch;

  globalThis.fetch = async () =>
    new Response(
      JSON.stringify({
        ok: false,
        findings: ["Validation rejected."],
      }),
      {
        status: 400,
        headers: { "Content-Type": "application/json" },
      },
    );

  try {
    await assert.rejects(
      submitGovernanceValidation(validInput),
      /Validation rejected/,
    );
  } finally {
    globalThis.fetch = originalFetch;
  }
});
TS

python3 <<'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

import_anchor = 'import { delegateCanonicalPackage } from "./governanceDelegationApi";'
if import_anchor not in text:
    raise SystemExit("Verified delegation import anchor not found")

if 'from "./governanceValidationApi"' not in text:
    text = text.replace(
        import_anchor,
        import_anchor + '\nimport { submitGovernanceValidation } from "./governanceValidationApi";',
        1,
    )

state_anchor = '''  const [delegationError, setDelegationError] =
    useState<string | null>(null);
'''
if state_anchor not in text:
    raise SystemExit("Delegation state anchor not found")

validation_state = '''  const [validating, setValidating] = useState(false);
  const [validationError, setValidationError] =
    useState<string | null>(null);
  const [validationComplete, setValidationComplete] = useState(false);
'''

if "const [validating, setValidating]" not in text:
    text = text.replace(
        state_anchor,
        state_anchor + validation_state,
        1,
    )

handler_anchor = '''  async function handleDelegate(): Promise<void> {
'''
if handler_anchor not in text:
    raise SystemExit("Delegate handler anchor not found")

delegated_section_anchor = '''      {pkg.delegation.state === "delegated" ? (
        <BriefingSection title="Delegation">
'''
if delegated_section_anchor not in text:
    raise SystemExit("Delegated section anchor not found")

handler = '''  async function handleValidate(): Promise<void> {
    if (
      validating ||
      validationComplete ||
      pkg.delegation.state !== "delegated"
    ) {
      return;
    }

    const validationStatus = window.prompt(
      "Validation status",
      "VALIDATION_PASSED",
    );

    if (!validationStatus?.trim()) {
      return;
    }

    setValidating(true);
    setValidationError(null);

    try {
      await submitGovernanceValidation({
        validation_result_id: crypto.randomUUID(),
        package_id: pkg.package_id,
        package_version: pkg.package_version,
        delegation_id: pkg.delegation.delegation_id,
        validation_status: validationStatus.trim(),
      });

      setValidationComplete(true);
    } catch (error) {
      setValidationError(
        error instanceof Error
          ? error.message
          : "Governance Validation could not be recorded.",
      );
    } finally {
      setValidating(false);
    }
  }

'''

if "async function handleValidate()" not in text:
    text = text.replace(
        handler_anchor,
        handler + handler_anchor,
        1,
    )

validation_ui = '''      {pkg.delegation.state === "delegated" ? (
        <section
          className="executive-decision-actions"
          aria-labelledby="executive-validation-action-title"
        >
          <div className="executive-decision-actions__heading">
            <div>
              <h3 id="executive-validation-action-title">
                Your Validation decision
              </h3>
              <p>
                Validation records the governance result for this exact
                delegated Canonical Package version. It does not authorize
                execution or advance the lifecycle automatically.
              </p>
            </div>
          </div>

          <div className="executive-decision-actions__options">
            <div className="executive-decision-option">
              <button
                type="button"
                className="executive-decision-button executive-decision-button--primary"
                disabled={validating || validationComplete}
                onClick={() => void handleValidate()}
              >
                {validationComplete
                  ? "Validated"
                  : validating
                    ? "Validating…"
                    : "Validate"}
              </button>

              <p>
                Explicitly records Validation for this delegated package only.
              </p>
            </div>
          </div>

          {validationError ? (
            <p
              className="executive-change-request__status"
              role="alert"
            >
              {validationError}
            </p>
          ) : null}
        </section>
      ) : null}

'''

if 'id="executive-validation-action-title"' not in text:
    text = text.replace(
        delegated_section_anchor,
        validation_ui + delegated_section_anchor,
        1,
    )

path.write_text(text)
PY

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check -- "$UI" "$API" "$TEST"

printf '\n=== GATE 2: ROOT TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: ADAPTER TESTS ===\n'
./node_modules/.bin/tsx --test "$TEST"

printf '\n=== GATE 4: CLIENT BUILD ===\n'
(
  cd client
  npm run build
)

printf '\n=== AUTHORIZED TARGET STATUS ===\n'
git status --short -- "$UI" "$API" "$TEST"

git add -- "$UI" "$API" "$TEST"

test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "3"
git diff --cached --name-only | grep -Fxq "$UI"
git diff --cached --name-only | grep -Fxq "$API"
git diff --cached --name-only | grep -Fxq "$TEST"

git commit -m "Expose explicit operator validation action"
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

trap - ERR

printf '\n=== ATTEMPT 2 RESULT ===\n'
echo "EXPLICIT_OPERATOR_VALIDATION_ACTION=IMPLEMENTED"
echo "OPERATOR_CLICK_REQUIRED=YES"
echo "DELEGATED_PACKAGE_ONLY=YES"
echo "AUTOMATIC_VALIDATION=NO"
echo "SERVER_CHANGE=NONE"
echo "DATABASE_CHANGE=NONE"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NONE"
echo "AUTO_ADVANCE=NONE"
echo "DOWNSTREAM_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"
echo "IMPLEMENTATION_HEAD=$(git rev-parse --short=9 HEAD)"
