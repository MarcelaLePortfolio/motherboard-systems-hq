#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN ORIGINAL UNSEEDED WIDER BASELINE COMPARISON ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY FAILURE-CLASSIFICATION CHECKPOINT ==="
expected_head="d37c31f2"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches failure-classification checkpoint $expected_head."
  exit 2
fi

echo "FAILURE_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY AUTHORIZED NEXT ACTION ==="
grep -nE \
  'BLOCKED_PENDING_BASELINE_COMPARISON|RUN_ORIGINAL_UNSEEDED_REASONING_AND_STRUCTURED_EVIDENCE_FIXTURES_ONCE_FOR_DIRECT_BASELINE_COMPARISON' \
  scripts/classify-wider-fixed-seed-single-run-failure.sh

echo "BASELINE_COMPARISON_AUTHORIZED=CONFIRMED"

echo
echo "=== VERIFY ORIGINAL FIXTURES REMAIN UNSEEDED ==="
for fixture in \
  scripts/validate-reasoning-composition-live.ts \
  scripts/validate-structured-evidence-object-live.ts
do
  if grep -q 'validationGenerationSeed' "$fixture"; then
    echo "STOP: original fixture unexpectedly contains validationGenerationSeed: $fixture"
    exit 2
  fi
done

echo "ORIGINAL_FIXTURES_UNSEEDED=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow supplies validationGenerationSeed."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent http://localhost:11434/api/tags >/dev/null
echo "OLLAMA_AVAILABLE"

artifact_dir="$(mktemp -d "${TMPDIR:-/tmp}/matilda-wider-unseeded-baseline.XXXXXX")"

echo
echo "ARTIFACT_DIRECTORY=$artifact_dir"

echo
echo "=== ORIGINAL UNSEEDED REASONING / EXPLANATION FIXTURE ==="
set +e
npx tsx scripts/validate-reasoning-composition-live.ts \
  >"$artifact_dir/reasoning.stdout.txt" \
  2>"$artifact_dir/reasoning.stderr.txt"
reasoning_rc=$?
set -e

cat "$artifact_dir/reasoning.stdout.txt"
cat "$artifact_dir/reasoning.stderr.txt"
echo "UNSEEDED_REASONING_EXIT_CODE=$reasoning_rc"

echo
echo "=== ORIGINAL UNSEEDED STRUCTURED-EVIDENCE FIXTURE ==="
set +e
npx tsx scripts/validate-structured-evidence-object-live.ts \
  >"$artifact_dir/evidence.stdout.txt" \
  2>"$artifact_dir/evidence.stderr.txt"
evidence_rc=$?
set -e

cat "$artifact_dir/evidence.stdout.txt"
cat "$artifact_dir/evidence.stderr.txt"
echo "UNSEEDED_STRUCTURED_EVIDENCE_EXIT_CODE=$evidence_rc"

failure_signature='Ollama returned a selected context segment that was not supplied in this invocation.'

reasoning_failure=0
evidence_failure=0

grep -qF "$failure_signature" "$artifact_dir/reasoning.stderr.txt" &&
  reasoning_failure=1 || true

grep -qF "$failure_signature" "$artifact_dir/evidence.stderr.txt" &&
  evidence_failure=1 || true

echo
echo "=== DIRECT BASELINE COMPARISON ==="
echo "UNSEEDED_REASONING_EXIT_CODE=$reasoning_rc"
echo "UNSEEDED_REASONING_UNSUPPLIED_SELECTED_CONTEXT_FAILURE=$reasoning_failure"
echo "UNSEEDED_STRUCTURED_EVIDENCE_EXIT_CODE=$evidence_rc"
echo "UNSEEDED_STRUCTURED_EVIDENCE_UNSUPPLIED_SELECTED_CONTEXT_FAILURE=$evidence_failure"
echo "ARTIFACT_DIRECTORY=$artifact_dir"

echo
echo "=== COMPARISON BOUNDARY ==="

if [[ "$reasoning_failure" -eq 1 && "$evidence_failure" -eq 1 ]]; then
  echo "UNSEEDED_BASELINE_MATCHES_FIXED_SEED_FAILURE_SURFACE=YES"
  echo "FIXED_SEED_SPECIFIC_REGRESSION_ESTABLISHED=NO"
  echo "NEXT_ACTION=CLASSIFY_WIDER_FIXTURE_BASELINE_COMPATIBILITY"
elif [[ "$reasoning_rc" -eq 0 && "$evidence_rc" -eq 0 ]]; then
  echo "UNSEEDED_BASELINE_MATCHES_FIXED_SEED_FAILURE_SURFACE=NO"
  echo "FIXED_SEED_SPECIFIC_REGRESSION_CANDIDATE=YES"
  echo "NEXT_ACTION=CLASSIFY_POTENTIAL_FIXED_SEED_WIDER_SEMANTIC_REGRESSION"
else
  echo "UNSEEDED_BASELINE_MATCHES_FIXED_SEED_FAILURE_SURFACE=MIXED_OR_DIFFERENT"
  echo "FIXED_SEED_SPECIFIC_REGRESSION_ESTABLISHED=NO"
  echo "NEXT_ACTION=CLASSIFY_MIXED_WIDER_BASELINE_COMPARISON"
fi

echo "NO_FIX_AUTHORIZED=YES"
echo "REPEATED_WIDER_RUNS_AUTHORIZED=NO"
echo "PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFY OBSERVATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/run-original-unseeded-wider-baseline-comparison\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside baseline-comparison scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "OBSERVATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
