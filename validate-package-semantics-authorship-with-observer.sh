#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATE PACKAGE SEMANTICS AUTHORSHIP WITH OBSERVER ==="
echo "EXPECTED_HEAD_PREFIX=8d18b6a4f"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "OBSERVER_IMPLEMENTATION_COMMIT=4091623efe9303cc75183c4240c8209de5da0e08"
echo "VALIDATION_MODE=DIAGNOSTIC_FIXED_SEED_ONLY"
echo "VALIDATION_SEED=424242"
echo "PRODUCTION_POLICY_CHANGE=NO"
echo "FAIL_CLOSED_VALIDATION_CHANGE=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 8d18b6a4f* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > scripts/validate-package-semantics-authorship-fixed-seed-live.ts << 'TS'
import {
  ollamaChat,
  type MatildaPackageSemanticsArtifact,
} from "./utils/ollamaChat";

const message = `
Create a non-authoritative package interpretation for this validation request.

Expected outcome: one reviewable checklist that visibly confirms the Approvals interface is displaying the actual request-specific package contents.

Proposed work: create a short verification checklist covering the package contents shown during approval review.

Proposed artifact: Package Approval UI Verification Checklist.

In scope: verifying that explicit request-specific package semantics, including the expected outcome, are preserved in Matilda's authored package semantics.

Out of scope: changing application code, changing approval authority, changing execution behavior, modifying historical packages, or approving the package automatically.

Constraints: preserve the existing one-message/one-workflow/one-Ollama-invocation architecture and keep the Living Draft non-authoritative until explicit user approval.

Unresolved question: whether the Approvals presentation needs additional visual refinement after all request-specific values are visible.
`.trim();

async function main(): Promise<void> {
  let observed:
    | MatildaPackageSemanticsArtifact
    | null
    | undefined;

  try {
    const result = await ollamaChat(
      message,
      {
        validationGenerationSeed: 424242,
        observeValidatedPackageSemantics:
          (packageSemantics) => {
            observed = packageSemantics;
          },
      },
    );

    console.log("OLLAMA_RESULT=ACCEPTED");
    console.log(
      "PUBLIC_RESULT_PACKAGE_SEMANTICS=" +
        JSON.stringify(
          result.packageSemantics,
          null,
          2,
        ),
    );
  } catch (error) {
    console.log("OLLAMA_RESULT=FAIL_CLOSED");
    console.log(
      "FAIL_CLOSED_ERROR=" +
        (
          error instanceof Error
            ? error.message
            : String(error)
        ),
    );
  }

  console.log(
    "OBSERVED_VALIDATED_PACKAGE_SEMANTICS=" +
      JSON.stringify(
        observed ?? null,
        null,
        2,
      ),
  );

  if (!observed) {
    throw new Error(
      "No validated packageSemantics artifact was observed.",
    );
  }

  if (
    typeof observed.expectedOutcome !== "string" ||
    !observed.expectedOutcome.trim()
  ) {
    throw new Error(
      "Explicit expectedOutcome was not preserved.",
    );
  }

  console.log(
    "EXPECTED_OUTCOME_PRESERVED=YES",
  );
  console.log(
    "EXPECTED_OUTCOME=" +
      observed.expectedOutcome,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
TS

echo
echo "=== FIXED-SEED AUTHORSHIP VALIDATION ==="
npx tsx \
  scripts/validate-package-semantics-authorship-fixed-seed-live.ts

echo
echo "=== INTERPRETATION BOUNDARY ==="
echo "THIS_ESTABLISHES=BOUNDED_DIAGNOSTIC_AUTHORSHIP_BEHAVIOR"
echo "THIS_DOES_NOT_ESTABLISH=PRODUCTION_GENERATION_STABILITY"
echo "LIVE_UNSEEDED_REVALIDATION_STATUS=SEPARATE"
echo "PRODUCTION_CHANGE=NONE"

git diff --check

git add scripts/validate-package-semantics-authorship-fixed-seed-live.ts
git commit -m "Add fixed-seed package semantics authorship validation"
git push
