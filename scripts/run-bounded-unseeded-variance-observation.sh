#!/usr/bin/env bash
set -u -o pipefail

echo "=== RUN BOUNDED UNSEEDED VARIANCE OBSERVATION ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY EXPECTED FIXTURE CLASSIFICATION CHECKPOINT ==="
if [[ "$(git rev-parse --short=8 HEAD)" != "dae7dc47" ]]; then
  echo "STOP: HEAD no longer matches fixture/runner classification checkpoint dae7dc47."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/run-bounded-unseeded-variance-observation\.sh$|^ M scripts/run-bounded-unseeded-variance-observation\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo "EXPECTED_FIXTURE_CLASSIFICATION_CHECKPOINT=CONFIRMED"

echo
echo "=== VERIFY CHARACTERIZATION CONTRACT ==="
grep -nE \
  'Initial bounded characterization sample: 10 identical unseeded invocations|validationGenerationSeed must remain absent|Do not retry a failed run' \
  scripts/define-bounded-unseeded-variance-characterization-contract.sh

echo "CHARACTERIZATION_CONTRACT=CONFIRMED"

echo
echo "=== VERIFY FIXTURE AND RUNNER CLASSIFICATION ==="
grep -nE \
  'FIXTURE_AND_RUNNER_BOUNDARY=CLASSIFIED|Execute exactly 10 sequential identical unseeded fixture invocations|NEXT_ACTION=IMPLEMENT_BOUNDED_UNSEEDED_VARIANCE_OBSERVATION_RUNNER' \
  scripts/classify-unseeded-variance-characterization-fixture-and-runner.sh

echo "FIXTURE_AND_RUNNER_CLASSIFICATION=CONFIRMED"

echo
echo "=== VERIFY FIXTURE REMAINS UNSEEDED ==="
if grep -nE \
  'validationGenerationSeed|seed:' \
  scripts/validate-adaptive-detail-mixed-content-live.ts
then
  echo "STOP: characterization fixture now supplies generation seed."
  exit 2
fi

echo "CHARACTERIZATION_FIXTURE_UNSEEDED=CONFIRMED"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS GENERATION-CONTROL FREE ==="
if grep -nE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow now supplies explicit generation controls."
  exit 2
fi

echo "PRODUCTION_WORKFLOW_GENERATION_CONTROL=ABSENT"

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent \
  http://localhost:11434/api/tags \
  >/dev/null

echo "OLLAMA_AVAILABLE"

artifact_dir="$(
  mktemp -d \
    "${TMPDIR:-/tmp}/matilda-unseeded-variance.XXXXXX"
)"

echo
echo "ARTIFACT_DIRECTORY=$artifact_dir"

total_runs=10
completed_runs=0
semantic_pass_runs=0
semantic_fail_runs=0
runtime_fail_runs=0
unique_fingerprints_file="$artifact_dir/fingerprints.txt"
summary_file="$artifact_dir/summary.tsv"

: > "$unique_fingerprints_file"

printf '%s\t%s\t%s\t%s\n' \
  "run" \
  "exit_code" \
  "classification" \
  "fingerprint" \
  > "$summary_file"

echo
echo "=== TEN-RUN UNSEEDED SAMPLE ==="

for run in $(seq 1 "$total_runs"); do
  stdout_file="$artifact_dir/run-${run}.stdout.txt"
  stderr_file="$artifact_dir/run-${run}.stderr.txt"

  echo
  echo "--- RUN $run OF $total_runs ---"

  set +e
  npx tsx \
    scripts/validate-adaptive-detail-mixed-content-live.ts \
    >"$stdout_file" \
    2>"$stderr_file"
  exit_code=$?
  set -e

  completed_runs=$((completed_runs + 1))

  fingerprint="$(
    cat "$stdout_file" "$stderr_file" |
    shasum -a 256 |
    awk '{print $1}'
  )"

  printf '%s\n' "$fingerprint" \
    >> "$unique_fingerprints_file"

  if [[ "$exit_code" -eq 0 ]] &&
     grep -q \
       'ADAPTIVE_DETAIL_MIXED_CONTENT_BEHAVIOR_SUPPORTED' \
       "$stdout_file"
  then
    classification="FIXTURE_SEMANTIC_PASS"
    semantic_pass_runs=$((semantic_pass_runs + 1))
  elif [[ "$exit_code" -eq 1 ]] ||
       grep -q \
         'ADAPTIVE_DETAIL_RUNTIME_REGRESSION_DETECTED' \
         "$stdout_file" "$stderr_file"
  then
    classification="FAIL_CLOSED_OR_RUNTIME_REJECTION"
    runtime_fail_runs=$((runtime_fail_runs + 1))
  else
    classification="FIXTURE_SEMANTIC_FAIL"
    semantic_fail_runs=$((semantic_fail_runs + 1))
  fi

  printf '%s\t%s\t%s\t%s\n' \
    "$run" \
    "$exit_code" \
    "$classification" \
    "$fingerprint" \
    >> "$summary_file"

  echo "RUN=$run"
  echo "EXIT_CODE=$exit_code"
  echo "CLASSIFICATION=$classification"
  echo "FINGERPRINT=$fingerprint"
  echo "STDOUT_ARTIFACT=$stdout_file"
  echo "STDERR_ARTIFACT=$stderr_file"
done

unique_fingerprints="$(
  sort -u "$unique_fingerprints_file" |
  wc -l |
  tr -d ' '
)"

echo
echo "=== SAMPLE SUMMARY ==="
echo "TOTAL_RUNS=$total_runs"
echo "COMPLETED_RUNS=$completed_runs"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$semantic_pass_runs"
echo "FIXTURE_SEMANTIC_FAIL_RUNS=$semantic_fail_runs"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$runtime_fail_runs"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"
echo "SUMMARY_ARTIFACT=$summary_file"

echo
echo "=== RUN MATRIX ==="
cat "$summary_file"

echo
echo "=== CHARACTERIZATION BOUNDARY ==="

if [[ "$runtime_fail_runs" -gt 0 || "$semantic_fail_runs" -gt 0 ]]; then
  echo "ACCEPTANCE_BOUNDARY_FAILURE_OBSERVED=YES"
  echo "NEXT_ACTION=CLASSIFY_PRESERVED_UNSEEDED_ACCEPTANCE_BOUNDARY_FAILURE"
else
  echo "ACCEPTANCE_BOUNDARY_FAILURE_OBSERVED=NO"
  echo "NEXT_ACTION=CLASSIFY_BOUNDED_UNSEEDED_VARIANCE_SAMPLE"
fi

if [[ "$unique_fingerprints" -gt 1 ]]; then
  echo "EXACT_OUTPUT_VARIANCE_OBSERVED=YES"
else
  echo "EXACT_OUTPUT_VARIANCE_OBSERVED=NO"
fi

echo "PRODUCTION_POLICY_RECOMMENDATION=NOT_DETERMINED_BY_RUNNER"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFY OBSERVATION-ONLY CHANGE SURFACE ==="
changed="$(
  git diff --name-only |
  grep -vE '^scripts/run-bounded-unseeded-variance-observation\.sh$' ||
  true
)"

if [[ -n "$changed" ]]; then
  echo "STOP: files outside observation-runner scope changed:"
  printf '%s\n' "$changed"
  exit 2
fi

echo "OBSERVATION_ONLY_CHANGE_SURFACE_CONFIRMED"

echo
echo "=== DIFF CHECK ==="
git diff --check
