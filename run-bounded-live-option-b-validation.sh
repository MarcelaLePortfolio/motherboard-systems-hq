#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RUN BOUNDED LIVE OPTION B VALIDATION ==="
echo "EXPECTED_HEAD_PREFIX=01d7865a1"
echo "AUTHORIZATION_COMMIT=01d7865a1b45efe6d5ac66bdbff4248516928c42"
echo "IMPLEMENTATION_COMMIT=11fc6efda"
echo "LIVE_RUN_COUNT=ONE"
echo "VALIDATION_SEED=NONE"
echo "RETRY_AUTHORIZED=NO"
echo "MODE=EXECUTION_WITH_BOUNDED_VALIDATION_AUTHORIZATION"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 01d7865a1* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > scripts/run-option-b-live-validation.ts << 'TS'
import { ollamaChat } from "./utils/ollamaChat";

const expectedOutcome =
  "One reviewable checklist that visibly confirms the Approvals interface is displaying the actual request-specific package contents.";

const message = [
  "Create a non-authoritative package interpretation for this validation request.",
  `Expected outcome: ${expectedOutcome}`,
  "Do not approve, canonicalize, delegate, route, assign, or execute anything.",
].join(" ");

async function main(): Promise<void> {
  console.log("=== LIVE OPTION B INVOCATION ===");
  console.log("VALIDATION_SEED=NONE");
  console.log("OLLAMA_INVOCATION_COUNT=ONE");
  console.log(`TYPED_EXPECTED_OUTCOME=${expectedOutcome}`);

  try {
    const result = await ollamaChat(message, {
      userPackageSemantics: {
        expectedOutcome,
      },
    });

    const actual = result.packageSemantics?.expectedOutcome ?? null;

    console.log("LIVE_RESULT=RETURNED");
    console.log(`AUTHORED_EXPECTED_OUTCOME=${JSON.stringify(actual)}`);
    console.log(
      `EXACT_TYPED_VALUE_PRESERVED=${actual === expectedOutcome ? "YES" : "NO"}`,
    );

    if (actual !== expectedOutcome) {
      throw new Error(
        "Live invocation returned without preserving the exact typed expectedOutcome.",
      );
    }

    console.log("OPTION_B_FIDELITY_BOUNDARY=PASSED");
  } catch (error) {
    const message =
      error instanceof Error ? error.message : String(error);

    console.log("LIVE_RESULT=FAIL_CLOSED");
    console.log(`ERROR=${message}`);

    if (/explicit user package semantics fidelity/i.test(message)) {
      console.log("OPTION_B_FIDELITY_BOUNDARY=REACHED_AND_REJECTED_MISMATCH");
      console.log("LIVE_OPTION_B_VALIDATION=CONCLUSIVE");
      return;
    }

    console.log("OPTION_B_FIDELITY_BOUNDARY=NOT_PROVEN_REACHED");
    console.log("LIVE_OPTION_B_VALIDATION=INCONCLUSIVE");
    process.exitCode = 2;
  }
}

void main();
TS

set +e
npx tsx scripts/run-option-b-live-validation.ts
STATUS=$?
set -e

echo
echo "=== VALIDATION CLASSIFICATION ==="
if [[ "${STATUS}" -eq 0 ]]; then
  echo "LIVE_VALIDATION_PROCESS_STATUS=CONCLUSIVE"
elif [[ "${STATUS}" -eq 2 ]]; then
  echo "LIVE_VALIDATION_PROCESS_STATUS=INCONCLUSIVE"
  echo "BLIND_RETRY=NO"
else
  echo "LIVE_VALIDATION_PROCESS_STATUS=UNEXPECTED_FAILURE"
  echo "BLIND_RETRY=NO"
fi

echo "GENERAL_PRODUCTION_GENERATION_STABILITY_PROOF=NO"
echo "PACKAGE_SEMANTICS_CORRIDOR_CLOSURE_AUTOMATIC=NO"

git diff --check

git add scripts/run-option-b-live-validation.ts run-bounded-live-option-b-validation.sh
git commit -m "Run bounded live typed package semantics validation"
git push

exit "${STATUS}"
