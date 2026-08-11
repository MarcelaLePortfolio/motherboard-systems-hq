#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY PHASE 3 REPEATED UNSEEDED VALIDATION RESULT ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-phase3-unseeded-stability.E1hIMl"

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY RUNNER CHECKPOINT ==="
required_runner_checkpoint="97126e1f"

if ! git merge-base --is-ancestor "$required_runner_checkpoint" HEAD; then
  echo "STOP: required Phase 3 runner checkpoint $required_runner_checkpoint is not an ancestor of HEAD."
  exit 2
fi

echo "REQUIRED_RUNNER_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY PRESERVED SAMPLE ==="

if [[ ! -d "$artifact_dir" ]]; then
  echo "STOP: preserved Phase 3 sample directory is unavailable."
  exit 2
fi

if [[ ! -f "$artifact_dir/summary.txt" ]]; then
  echo "STOP: Phase 3 sample summary is unavailable."
  exit 2
fi

echo "PRESERVED_PHASE_3_SAMPLE=CONFIRMED"

echo
echo "=== SAMPLE SUMMARY ==="
cat "$artifact_dir/summary.txt"

total_runs="$(grep -c '^RUN=' "$artifact_dir/summary.txt")"
semantic_pass_runs="$(grep -c '^CLASSIFICATION=FIXTURE_SEMANTIC_PASS$' "$artifact_dir/summary.txt" || true)"
runtime_rejection_runs="$(grep -c '^CLASSIFICATION=FAIL_CLOSED_OR_RUNTIME_REJECTION$' "$artifact_dir/summary.txt" || true)"
semantic_failure_runs="$(grep -c '^CLASSIFICATION=FIXTURE_SEMANTIC_FAILURE$' "$artifact_dir/summary.txt" || true)"
unique_fingerprints="$(
  grep '^FINGERPRINT=' "$artifact_dir/summary.txt" |
  cut -d= -f2 |
  sort -u |
  wc -l |
  tr -d ' '
)"

echo
echo "TOTAL_RUNS=$total_runs"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$semantic_pass_runs"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$runtime_rejection_runs"
echo "FIXTURE_SEMANTIC_FAILURE_RUNS=$semantic_failure_runs"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"

if [[ "$total_runs" -ne 10 ]]; then
  echo "STOP: preserved sample does not contain exactly ten runs."
  exit 2
fi

if [[ "$semantic_pass_runs" -ne 0 ]]; then
  echo "STOP: expected zero semantic-pass runs."
  exit 2
fi

if [[ "$runtime_rejection_runs" -ne 8 ]]; then
  echo "STOP: expected eight fail-closed/runtime-rejection runs."
  exit 2
fi

if [[ "$semantic_failure_runs" -ne 2 ]]; then
  echo "STOP: expected two fixture-semantic-failure runs."
  exit 2
fi

if [[ "$unique_fingerprints" -ne 3 ]]; then
  echo "STOP: expected three unique exact-output fingerprints."
  exit 2
fi

echo "PHASE_3_SAMPLE_COUNTS=CONFIRMED"

echo
echo "=== VERIFY CURRENT PRODUCTION BASELINE REMAINS UNCHANGED ==="

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

production_call_count="$(
  grep -c 'await ollamaChat(message' server/matilda-chat-workflow.ts || true
)"

if [[ "$production_call_count" -ne 1 ]]; then
  echo "STOP: production workflow no longer has exactly one ollamaChat invocation."
  exit 2
fi

echo "PRODUCTION_BASELINE=UNCHANGED"

echo
echo "=== RESULT CLASSIFICATION ==="

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=REPEATED_UNSEEDED_BEHAVIORAL_VALIDATION
UNIT=PHASE_3_REPEATED_UNSEEDED_VALIDATION_RESULT

PHASE_3_SAMPLE=
  TOTAL_RUNS=10
  FIXTURE_SEMANTIC_PASS_RUNS=0
  FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=8
  FIXTURE_SEMANTIC_FAILURE_RUNS=2
  UNIQUE_EXACT_OUTPUT_FINGERPRINTS=3

STABLE_ACCEPTANCE_CRITERION=
  FAIL

UNQUALIFIED_STABLE=
  NO

PHASE_3_PRODUCTION_STABILITY_RESULT=
  UNSTABLE

FAIL_CLOSED_ENFORCEMENT_RESULT=
  PRESERVED

PRIMARY_DETERMINISTIC_REJECTION_SURFACE=
  UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE

SEMANTIC_FAILURE_RESULT=
  TWO_RUNS_RETURNED_WITHOUT_ADAPTER_REJECTION_BUT_FAILED_THE_ESTABLISHED_FIXTURE_ACCEPTANCE_SURFACE

INTERPRETATION=
  The bounded Phase 3 production sample does not establish production
  stability.

  Zero of ten ordinary unseeded runs satisfied the established Adaptive
  Detail semantic acceptance surface.

  Eight runs were rejected by the existing deterministic fail-closed
  boundary because model-authored project-context support provenance was
  invalid.

  Two additional runs returned successfully from the adapter but failed the
  fixture semantic contract.

  The production generation behavior is therefore unstable on the
  established validation surface while deterministic fail-closed enforcement
  remains operational.

DETERMINISTIC_VALIDATOR_STATUS=
  PRESERVE

PRODUCTION_RUNTIME_REGRESSION=
  NOT_ESTABLISHED

PRODUCTION_POLICY_STATUS=
  DEFERRED_BY_PHASE_2

FIXED_SEED_EVIDENCE_STATUS=
  DIAGNOSTIC_ONLY
  DO_NOT_PROMOTE_FROM_THIS_RESULT

PRODUCTION_IMPLEMENTATION_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=
  NO

PRODUCTION_GENERATION_POLICY=
  UNCHANGED

PRODUCTION_CHANGE=
  NONE

PHASE_3_REPEATED_VALIDATION_STATUS=
  COMPLETE

NEXT_CORRIDOR=
  FAIL_CLOSED_CONTRACT_PRESERVATION

NEXT_ACTION=
  CLASSIFY_PHASE_3_FAIL_CLOSED_CONTRACT_PRESERVATION
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-phase-3-repeated-unseeded-validation-result\.sh$' ||
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
