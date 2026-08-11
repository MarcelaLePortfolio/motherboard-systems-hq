#!/usr/bin/env bash
set -euo pipefail

echo "=== DEFINE WIDER FIXED-SEED SEMANTIC PRESERVATION VALIDATION CONTRACT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY FIXED-SEED RESULT CHECKPOINT ==="
expected_head="49e91dfb"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches fixed-seed result checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/define-wider-fixed-seed-semantic-preservation-validation-contract\.sh$|^ M scripts/define-wider-fixed-seed-semantic-preservation-validation-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "FIXED_SEED_RESULT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY SUPPORTED DIAGNOSTIC RESULT ==="
grep -nE \
  'DIAGNOSTIC_CANDIDATE_RESULT=SUPPORTED|FIXED_SEED_DIAGNOSTIC_CANDIDATE_SUPPORTED|BLOCKED_PENDING_WIDER_SEMANTIC_PRESERVATION_EVIDENCE|NEXT_CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY' \
  scripts/classify-bounded-fixed-seed-diagnostic-result.sh

echo "SUPPORTED_DIAGNOSTIC_RESULT=CONFIRMED"

echo
echo "=== INVENTORY EXISTING SEMANTIC RESPONSIBILITY TEST SURFACES ==="
find scripts/utils -maxdepth 1 -type f -name 'ollamaChat*.test.ts' | sort

echo
echo "=== INVENTORY EXISTING LIVE VALIDATION SURFACES ==="
find scripts -maxdepth 1 -type f \( \
  -name 'validate-*live.ts' -o \
  -name 'validate-*live-validation.sh' \
\) | sort

echo
echo "=== WIDER SEMANTIC PRESERVATION CONTRACT ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY

GOVERNING_QUESTION=
  Does the supported fixed-seed diagnostic candidate preserve the wider
  established semantic responsibilities of the Conversation Engine strongly
  enough to remain eligible for later production-policy consideration?

CANDIDATE=
  validationGenerationSeed=424242

CANDIDATE_STATUS=
  DIAGNOSTICALLY_SUPPORTED_ON_KNOWN_FAILURE_FIXTURE

PRODUCTION_STATUS=
  NOT_AUTHORIZED

VALIDATION_CLASS=
  WIDER_SEMANTIC_PRESERVATION_DIAGNOSTIC

VALIDATION_PURPOSE=
  Test whether fixing the sampling state preserves established semantic
  behavior across multiple independent structured-response responsibilities,
  rather than only solving the Adaptive Detail support-identity fixture.

REQUIRED_RESPONSIBILITY_CLASSES=
  1. Summary Composition
  2. Reasoning / Explanation Composition
  3. Evidence / Support Provenance
  4. Boundary Composition
  5. Selected Context / Adaptive Detail
  6. Investigation Lifecycle
  7. Durable Interpretation
  8. Structured Response Contract / Fail-Closed Behavior

TEST_SELECTION_RULE=
  Reuse already established repository tests and live validators where possible.

  Do not invent new semantic requirements merely to exercise the candidate.

  Prefer independently established acceptance criteria over candidate-specific
  assertions.

FIXED_VARIABLE=
  validationGenerationSeed=424242

PROHIBITED_CONCURRENT_CHANGES=
  - no temperature change;
  - no top_p change;
  - no top_k change;
  - no model change;
  - no prompt rewrite;
  - no identity-presentation rewrite;
  - no schema change;
  - no validator relaxation;
  - no retries;
  - no second model invocation;
  - no semantic-history change;
  - no production workflow change.

VALIDATION_SHAPE=
  For each selected semantic responsibility, execute the smallest available
  seeded diagnostic equivalent that preserves the original fixture meaning and
  acceptance criteria.

  Where no seeded equivalent exists, classify the smallest safe diagnostic
  adaptation before implementing or running it.

ACCEPTANCE_REQUIREMENT=
  Every selected responsibility must satisfy its established semantic and
  structural acceptance criteria under the fixed diagnostic seed.

FAIL_CLOSED_REQUIREMENT=
  Existing invalid-output rejection behavior must remain intact.

SEMANTIC_QUALITY_REQUIREMENT=
  Fixed seeding must not cause a previously established semantic responsibility
  to become incomplete, materially incorrect, overinclusive, unsupported, or
  structurally invalid.

EXACT_REPEATABILITY_REQUIREMENT=
  NOT_PRIMARY

  Exact repeatability may be observed but semantic preservation is the governing
  acceptance criterion.

CANDIDATE_SURVIVAL_RULE=
  The fixed-seed candidate remains eligible only if all selected wider semantic
  responsibilities pass without requiring production-boundary relaxation.

FAILURE_RULE=
  If any responsibility fails, preserve the failure artifact and classify that
  specific semantic regression before considering another intervention.

NO_POLICY_PROMOTION_FROM_PARTIAL_PASS=
  Passing some responsibilities does not authorize production promotion.

PRODUCTION_PROMOTION_GATE=
  Even full wider semantic preservation does not itself authorize implementation.

  A separate production generation-policy and control boundary must still
  establish ownership, configuration semantics, rollback, operational safety,
  and explicit implementation authorization.

IMPLEMENTATION_AUTHORIZED=
  DIAGNOSTIC_VALIDATION_ONLY

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_GENERATION_POLICY=UNCHANGED
PRODUCTION_CHANGE=NONE

CORRIDOR_RESULT=
  WIDER_FIXED_SEED_SEMANTIC_PRESERVATION_CONTRACT_DEFINED

NEXT_ACTION=
  CLASSIFY_WIDER_SEMANTIC_PRESERVATION_FIXTURE_SET
MAP

echo
echo "=== VERIFY CONTRACT-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/define-wider-fixed-seed-semantic-preservation-validation-contract\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside contract-definition scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CONTRACT_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/define-wider-fixed-seed-semantic-preservation-validation-contract.sh
git diff --cached --check
git commit -m "Define wider fixed seed semantic preservation contract"
git push
