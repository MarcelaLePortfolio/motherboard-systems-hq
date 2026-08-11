#!/usr/bin/env bash
set -euo pipefail

echo "=== CLASSIFY BOUNDED FIXED-SEED DIAGNOSTIC RESULT ==="

artifact_dir="/var/folders/3n/zscyzgr50b9gk8dg6fv8byz80000gn/T//matilda-fixed-seed-diagnostic.dJ6VmX"

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY DIAGNOSTIC RUNNER CHECKPOINT ==="
required_runner_commit="327abd36"

if ! git merge-base --is-ancestor "$required_runner_commit" HEAD; then
  echo "STOP: required diagnostic runner checkpoint $required_runner_commit is not an ancestor of HEAD."
  exit 2
fi

echo "REQUIRED_DIAGNOSTIC_RUNNER_ANCESTOR_PRESENT=$required_runner_commit"

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/classify-bounded-fixed-seed-diagnostic-result\.sh$|^ M scripts/classify-bounded-fixed-seed-diagnostic-result\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VERIFY PRESERVED SAMPLE ==="

summary="$artifact_dir/summary.tsv"

if [[ ! -d "$artifact_dir" || ! -f "$summary" ]]; then
  echo "STOP: preserved fixed-seed diagnostic artifacts are unavailable."
  exit 2
fi

echo "PRESERVED_SAMPLE_DIRECTORY=$artifact_dir"

echo
echo "=== SAMPLE SUMMARY ==="
cat "$summary"

total_runs="$(
  tail -n +2 "$summary" |
  wc -l |
  tr -d ' '
)"

pass_runs="$(
  awk -F '\t' \
    '$3 == "FIXTURE_SEMANTIC_PASS" { count++ } END { print count+0 }' \
    "$summary"
)"

failure_runs="$(
  awk -F '\t' \
    '$3 == "FAIL_CLOSED_OR_RUNTIME_REJECTION" { count++ } END { print count+0 }' \
    "$summary"
)"

unique_fingerprints="$(
  tail -n +2 "$summary" |
  cut -f4 |
  sort -u |
  wc -l |
  tr -d ' '
)"

line22_runs="$(
  {
    grep -l '^INVALID_PARENT_LINE_22=true$' \
      "$artifact_dir"/run-*.stdout.txt \
      2>/dev/null ||
    true
  } |
  wc -l |
  tr -d ' '
)"

echo
echo "TOTAL_RUNS=$total_runs"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$pass_runs"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$failure_runs"
echo "CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITY_RUNS=$line22_runs"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"

if [[ "$total_runs" -ne 10 ||
      "$pass_runs" -ne 10 ||
      "$failure_runs" -ne 0 ||
      "$line22_runs" -ne 0 ||
      "$unique_fingerprints" -ne 1 ]]; then
  echo "STOP: preserved sample does not satisfy the bounded fixed-seed diagnostic acceptance contract."
  exit 2
fi

echo "DIAGNOSTIC_ACCEPTANCE_COUNTS=CONFIRMED"
echo "EXACT_REPEATABILITY=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="

if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow now supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== RESULT CLASSIFICATION ==="
cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=GENERATION_POLICY_AND_CONTROL_BOUNDARY
CORRIDOR=FIXED_SEED_DIAGNOSTIC_EXPERIMENT_RESULT

FIXED_SEED=424242

UNSEEDED_BASELINE=
  1_OF_10_FIXTURE_SEMANTIC_PASS
  9_OF_10_FAIL_CLOSED_OR_RUNTIME_REJECTION
  9_OF_10_CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITIES
  2_UNIQUE_EXACT_OUTPUT_FINGERPRINTS

FIXED_SEED_RESULT=
  10_OF_10_FIXTURE_SEMANTIC_PASS
  0_OF_10_FAIL_CLOSED_OR_RUNTIME_REJECTION
  0_OF_10_CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITIES
  1_UNIQUE_EXACT_OUTPUT_FINGERPRINT

DIAGNOSTIC_CANDIDATE_RESULT=SUPPORTED
PRIMARY_ACCEPTANCE_CRITERION=PASS
KNOWN_FAILURE_ACCEPTANCE_CRITERION=PASS
FAIL_CLOSED_ACCEPTANCE_CRITERION=PASS
EXACT_REPEATABILITY_OBSERVED=YES

CLASSIFICATION=
  The bounded fixed-seed diagnostic eliminated the previously observed
  acceptance-boundary failure for this fixture and produced exact repeatability
  across all ten runs.

  This establishes the existing request-scoped fixed seed as a supported
  diagnostic stabilization candidate for this failure surface.

  It does not establish that fixed seeding is an acceptable production policy
  across the wider Conversation Engine semantic surface.

PRODUCTION_POLICY_DECISION=NOT_YET_AUTHORIZED
PRODUCTION_PROMOTION_STATUS=BLOCKED_PENDING_WIDER_SEMANTIC_PRESERVATION_EVIDENCE

DETERMINISTIC_VALIDATOR=PRESERVE
STRUCTURED_RESPONSE_SCHEMA=PRESERVE
SELECTED_CONTEXT_IDENTITY=PRESERVE
SUPPORT_PROVENANCE_IDENTITY=PRESERVE
PRODUCTION_WORKFLOW=UNCHANGED

CORRIDOR_RESULT=FIXED_SEED_DIAGNOSTIC_CANDIDATE_SUPPORTED

IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO
PRODUCTION_CHANGE=NONE

NEXT_CORRIDOR=GENERATION_CONTROL_SEMANTIC_PRESERVATION_BOUNDARY
NEXT_ACTION=DEFINE_WIDER_FIXED_SEED_SEMANTIC_PRESERVATION_VALIDATION_CONTRACT
MAP

echo
echo "=== VERIFY CLASSIFICATION-ONLY CHANGE SURFACE ==="

changed="$(
  git diff --name-only |
  grep -vE '^scripts/classify-bounded-fixed-seed-diagnostic-result\.sh$' ||
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
