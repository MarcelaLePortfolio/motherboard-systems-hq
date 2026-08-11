#!/usr/bin/env bash
set -euo pipefail

echo "=== RUN BOUNDED FIXED-SEED DIAGNOSTIC EXPERIMENT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY FIXTURE CLASSIFICATION ANCESTOR ==="
required_checkpoint="36422003"

if ! git merge-base --is-ancestor "$required_checkpoint" HEAD; then
  echo "STOP: required fixture classification checkpoint $required_checkpoint is not an ancestor of HEAD."
  exit 2
fi

echo "REQUIRED_FIXTURE_CLASSIFICATION_ANCESTOR_PRESENT=$required_checkpoint"

echo
echo "=== VERIFY EXPERIMENT CONTRACT ==="
grep -nE \
  '10_OF_10_FIXTURE_SEMANTIC_PASS|0_OF_10_CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITIES|PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO' \
  scripts/define-bounded-intervention-experiment-acceptance-contract.sh

echo "EXPERIMENT_CONTRACT=CONFIRMED"

echo
echo "=== VERIFY FIXED SEED ==="
grep -nF 'const VALIDATION_SEED = 424242;' \
  scripts/validate-adaptive-detail-mixed-content-seeded-live.ts

echo "FIXED_VALIDATION_SEED=424242"

echo
echo "=== VERIFY PRODUCTION WORKFLOW REMAINS UNSEEDED ==="
if grep -q 'validationGenerationSeed' server/matilda-chat-workflow.ts; then
  echo "STOP: production workflow now supplies validationGenerationSeed."
  exit 2
fi
echo "PRODUCTION_WORKFLOW_VALIDATION_SEED=ABSENT"

echo
echo "=== OLLAMA AVAILABILITY ==="
curl --fail --silent http://localhost:11434/api/tags >/dev/null
echo "OLLAMA_AVAILABLE"

artifact_dir="$(mktemp -d "${TMPDIR:-/tmp}/matilda-fixed-seed-diagnostic.XXXXXX")"
summary="$artifact_dir/summary.tsv"

echo
echo "ARTIFACT_DIRECTORY=$artifact_dir"
printf 'run\texit_code\tclassification\tfingerprint\n' > "$summary"

pass_runs=0
failure_runs=0
line22_runs=0

echo
echo "=== TEN-RUN FIXED-SEED SAMPLE ==="

for run in $(seq 1 10); do
  stdout_file="$artifact_dir/run-$run.stdout.txt"
  stderr_file="$artifact_dir/run-$run.stderr.txt"

  echo
  echo "--- RUN $run OF 10 ---"

  set +e
  npx tsx \
    scripts/validate-adaptive-detail-mixed-content-seeded-live.ts \
    >"$stdout_file" \
    2>"$stderr_file"
  rc=$?
  set -e

  if [[ "$rc" -eq 0 ]] &&
     grep -q '^SEEDED_ADAPTIVE_DETAIL_BEHAVIOR_SUPPORTED$' "$stdout_file"; then
    classification="FIXTURE_SEMANTIC_PASS"
    pass_runs=$((pass_runs + 1))
  else
    classification="FAIL_CLOSED_OR_RUNTIME_REJECTION"
    failure_runs=$((failure_runs + 1))
  fi

  if grep -q '^INVALID_PARENT_LINE_22=true$' "$stdout_file"; then
    line22_runs=$((line22_runs + 1))
  fi

  fingerprint="$(
    {
      cat "$stdout_file"
      cat "$stderr_file"
    } | shasum -a 256 | awk '{print $1}'
  )"

  printf '%s\t%s\t%s\t%s\n' \
    "$run" "$rc" "$classification" "$fingerprint" >> "$summary"

  echo "RUN=$run"
  echo "EXIT_CODE=$rc"
  echo "CLASSIFICATION=$classification"
  echo "FINGERPRINT=$fingerprint"
  echo "STDOUT_ARTIFACT=$stdout_file"
  echo "STDERR_ARTIFACT=$stderr_file"
done

unique_fingerprints="$(
  tail -n +2 "$summary" |
  cut -f4 |
  sort -u |
  wc -l |
  tr -d ' '
)"

echo
echo "=== FIXED-SEED DIAGNOSTIC SUMMARY ==="
cat "$summary"

echo
echo "TOTAL_RUNS=10"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$pass_runs"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$failure_runs"
echo "CHILD_DERIVED_LINE_22_PARENT_SUPPORT_IDENTITY_RUNS=$line22_runs"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"

echo
echo "=== ACCEPTANCE CLASSIFICATION ==="

if [[ "$pass_runs" -eq 10 &&
      "$failure_runs" -eq 0 &&
      "$line22_runs" -eq 0 ]]; then
  echo "DIAGNOSTIC_CANDIDATE_RESULT=SUPPORTED"
  echo "PRIMARY_ACCEPTANCE_CRITERION=PASS"
  echo "KNOWN_FAILURE_ACCEPTANCE_CRITERION=PASS"
  echo "FAIL_CLOSED_ACCEPTANCE_CRITERION=PASS"
  echo "NEXT_ACTION=CLASSIFY_BOUNDED_FIXED_SEED_DIAGNOSTIC_RESULT"
else
  echo "DIAGNOSTIC_CANDIDATE_RESULT=NOT_ESTABLISHED"
  echo "PRIMARY_ACCEPTANCE_CRITERION=FAIL"
  echo "NEXT_ACTION=CLASSIFY_PRESERVED_FIXED_SEED_DIAGNOSTIC_FAILURE"
fi

if [[ "$unique_fingerprints" -eq 1 ]]; then
  echo "EXACT_REPEATABILITY_OBSERVED=YES"
else
  echo "EXACT_REPEATABILITY_OBSERVED=NO"
fi

echo "PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFY OBSERVATION-ONLY EXECUTION ==="
git diff --check
