#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY FIXED-SEED DIAGNOSTIC EXPERIMENT FIXTURE AND RUNNER ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY ACCEPTANCE-CONTRACT CHECKPOINT ==="
expected_head="b6cb60ed"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches acceptance-contract checkpoint $expected_head."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-fixed-seed-diagnostic-experiment-fixture-and-runner\.sh$|^ M scripts/classify-fixed-seed-diagnostic-experiment-fixture-and-runner\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "ACCEPTANCE_CONTRACT_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY ACCEPTANCE CONTRACT ==="
grep -nE \
  'FIRST_CANDIDATE_CLASS=|EXISTING_REQUEST_SCOPED_VALIDATION_SEED|CANDIDATE_VARIABLE=|validationGenerationSeed only|SAMPLE_BOUNDARY=|10 sequential identical fixture invocations|PRIMARY_CANDIDATE_ACCEPTANCE_CRITERION=|10_OF_10_FIXTURE_SEMANTIC_PASS|PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO|NEXT_ACTION=|CLASSIFY_FIXED_SEED_DIAGNOSTIC_EXPERIMENT_FIXTURE_AND_RUNNER' \
  scripts/define-bounded-intervention-experiment-acceptance-contract.sh

echo "ACCEPTANCE_CONTRACT=CONFIRMED"

echo
echo "=== EXISTING MIXED-CONTENT FIXTURE ==="
sed -n '1,220p' scripts/validate-adaptive-detail-mixed-content-live.ts

echo
echo "=== EXISTING SEEDED MIXED-CONTENT FIXTURE ==="
if [[ -f scripts/validate-adaptive-detail-mixed-content-seeded-live.ts ]]; then
  sed -n '1,240p' scripts/validate-adaptive-detail-mixed-content-seeded-live.ts
else
  echo "SEEDED_MIXED_CONTENT_FIXTURE=ABSENT"
fi

echo
echo "=== EXISTING SEEDED REPRODUCIBILITY RUNNER ==="
if [[ -f scripts/validate-adaptive-detail-seeded-reproducibility.sh ]]; then
  sed -n '1,280p' scripts/validate-adaptive-detail-seeded-reproducibility.sh
else
  echo "SEEDED_REPRODUCIBILITY_RUNNER=ABSENT"
fi

echo
echo "=== VERIFY DIAGNOSTIC SEED TRANSPORT ==="
grep -nE \
  'validationGenerationSeed|seed: context\.validationGenerationSeed' \
  scripts/utils/ollamaChat.ts

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -n 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== VERIFY PRIOR SEEDED ACCEPTANCE EVIDENCE ==="
grep -nE \
  'All three seeded runs produced|No seeded run emitted the invalid child-derived :22 parent identity|Seeded reproducibility does not prove|production seed should not yet be implemented' \
  scripts/classify-adaptive-detail-stability-from-seeded-evidence.sh

echo "PRIOR_SEEDED_ACCEPTANCE_EVIDENCE=CONFIRMED"

echo
echo "=== FIXTURE AND RUNNER CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=FIXED_SEED_DIAGNOSTIC_EXPERIMENT_FIXTURE_AND_RUNNER

EXPERIMENT_CLASS=
  DIAGNOSTIC_ONLY

CANDIDATE=
  EXISTING_REQUEST_SCOPED_VALIDATION_SEED

ESTABLISHED_FIXTURE=
  ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE

FIXTURE_REQUIREMENT=
  The experiment must preserve the same semantic fixture that produced the
  established ordinary-unseeded baseline failure.

REQUIRED_PARENT_SUPPORT_IDENTITY=
  docs/adaptive-detail-live-validation.md:20

KNOWN_INVALID_CHILD_DERIVED_PARENT_IDENTITY=
  docs/adaptive-detail-live-validation.md:22

EXISTING_SEEDED_FIXTURE_STATUS=
  REUSE_IF_SEMANTICALLY_IDENTICAL

  If the existing seeded mixed-content fixture differs materially from the
  established unseeded fixture in user message, supplied context, assertions,
  prompt path, schema, or deterministic validator, do not use it silently.

  Instead create the smallest diagnostic-only fixture adaptation that changes
  validationGenerationSeed and nothing else.

SEED_SELECTION_BOUNDARY=
  Reuse the fixed diagnostic seed already established by prior seeded
  reproducibility evidence.

  Do not search across seeds for a favorable result.

  Do not choose a seed by repeatedly trying values until the fixture passes.

RUNNER_REQUIREMENT=
  Execute exactly 10 sequential identical seeded invocations.

  Each invocation must use the same fixed validationGenerationSeed.

  The runner must continue through all ten runs even if one run fails so the
  complete bounded sample is preserved.

ARTIFACT_REQUIREMENT=
  Preserve stdout and stderr independently for every run.

  Preserve a summary artifact containing:

  - run number;
  - exit code;
  - fixture-semantic classification;
  - exact-output fingerprint.

REQUIRED_AGGREGATES=
  - total runs;
  - fixture-semantic-pass runs;
  - fail-closed/runtime-rejection runs;
  - known line-22 failure-signature runs;
  - unique exact-output fingerprints.

PASS_CONTRACT=
  FIXTURE_SEMANTIC_PASS_RUNS=10
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=0
  CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITY_RUNS=0

EXACT_REPEATABILITY=
  OBSERVE_BUT_DO_NOT_REQUIRE

  Multiple fingerprints do not invalidate the candidate if all ten runs remain
  inside established structural and semantic acceptance boundaries.

FAILURE_HANDLING=
  If any run crosses an acceptance boundary, preserve the complete sample and
  classify the failure before attempting another intervention.

NO_AUTOMATIC_SECOND_CANDIDATE=
  Do not proceed directly to identity-presentation intervention merely because
  the fixed-seed candidate fails.

  First classify what failed and whether the result changes the intervention
  hypothesis.

PROHIBITED_RUNNER_BEHAVIOR=
  - no retries replacing failed runs;
  - no discarded runs;
  - no seed changes between runs;
  - no temperature change;
  - no top_p change;
  - no top_k change;
  - no prompt change;
  - no identity-presentation change;
  - no schema relaxation;
  - no deterministic-validator relaxation;
  - no production workflow change.

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

FIXTURE_AND_RUNNER_BOUNDARY=
  CLASSIFIED

IMPLEMENTATION_AUTHORIZED=
  DIAGNOSTIC_RUNNER_ONLY

NEXT_ACTION=
  IMPLEMENT_BOUNDED_FIXED_SEED_DIAGNOSTIC_EXPERIMENT_RUNNER
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-fixed-seed-diagnostic-experiment-fixture-and-runner\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside classification scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "CLASSIFICATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-fixed-seed-diagnostic-experiment-fixture-and-runner.sh
git diff --cached --check
git commit -m "Classify fixed seed diagnostic experiment fixture"
git push
