#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 REPEATED UNSEEDED PRODUCTION STABILITY VALIDATION ==="

expected_head="842e5ec5"

if [[ "$(git rev-parse --short=8 HEAD)" != "$expected_head" ]]; then
  echo "STOP: HEAD no longer matches authorized runner-classification checkpoint $expected_head."
  exit 2
fi

fixture="scripts/validate-adaptive-detail-mixed-content-live.ts"

if [[ ! -f "$fixture" ]]; then
  echo "STOP: required Phase 3 fixture missing: $fixture"
  exit 2
fi

if grep -q 'validationGenerationSeed' "$fixture"; then
  echo "STOP: Phase 3 fixture unexpectedly contains validationGenerationSeed."
  exit 2
fi

if grep -qE \
  'validationGenerationSeed|temperature:|top_p:|top_k:|seed:' \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production workflow contains explicit generation control."
  exit 2
fi

artifact_dir="$(mktemp -d "${TMPDIR:-/tmp}/matilda-phase3-unseeded-stability.XXXXXX")"
summary_file="$artifact_dir/summary.txt"

semantic_pass=0
runtime_rejection=0
semantic_failure=0

: > "$summary_file"

echo "ARTIFACT_DIRECTORY=$artifact_dir"
echo "RUN_COUNT=10"
echo "GENERATION_POLICY=UNSEEDED_UNCHANGED"
echo "RETRY_POLICY=NONE"
echo

for run in $(seq 1 10); do
  stdout_file="$artifact_dir/run-${run}.stdout.txt"
  stderr_file="$artifact_dir/run-${run}.stderr.txt"
  metadata_file="$artifact_dir/run-${run}.metadata.txt"

  echo "=== RUN $run OF 10 ==="

  set +e
  npx tsx "$fixture" >"$stdout_file" 2>"$stderr_file"
  rc=$?
  set -e

  combined="$artifact_dir/run-${run}.combined.txt"
  cat "$stdout_file" "$stderr_file" >"$combined"

  fingerprint="$(shasum -a 256 "$combined" | awk '{print $1}')"

  if [[ "$rc" -eq 0 ]] && grep -q 'ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_SUPPORTED' "$stdout_file"; then
    classification="FIXTURE_SEMANTIC_PASS"
    semantic_pass=$((semantic_pass + 1))
  elif [[ "$rc" -ne 0 ]]; then
    classification="FAIL_CLOSED_OR_RUNTIME_REJECTION"
    runtime_rejection=$((runtime_rejection + 1))
  else
    classification="FIXTURE_SEMANTIC_FAILURE"
    semantic_failure=$((semantic_failure + 1))
  fi

  {
    echo "RUN=$run"
    echo "EXIT_CODE=$rc"
    echo "CLASSIFICATION=$classification"
    echo "FINGERPRINT=$fingerprint"
  } > "$metadata_file"

  cat "$metadata_file"
  echo

  {
    echo "RUN=$run"
    echo "EXIT_CODE=$rc"
    echo "CLASSIFICATION=$classification"
    echo "FINGERPRINT=$fingerprint"
  } >> "$summary_file"
done

unique_fingerprints="$(
  grep '^FINGERPRINT=' "$summary_file" |
  cut -d= -f2 |
  sort -u |
  wc -l |
  tr -d ' '
)"

failure_signatures="$(
  grep -hE \
    'Error:|Ollama returned .* not supplied in this invocation|ADAPTIVE_DETAIL.*FAIL|selected context|support reference' \
    "$artifact_dir"/run-*.stderr.txt \
    "$artifact_dir"/run-*.stdout.txt \
    2>/dev/null |
  sort -u || true
)"

echo "=== PHASE 3 SAMPLE SUMMARY ==="
echo "TOTAL_RUNS=10"
echo "FIXTURE_SEMANTIC_PASS_RUNS=$semantic_pass"
echo "FAIL_CLOSED_OR_RUNTIME_REJECTION_RUNS=$runtime_rejection"
echo "FIXTURE_SEMANTIC_FAILURE_RUNS=$semantic_failure"
echo "UNIQUE_EXACT_OUTPUT_FINGERPRINTS=$unique_fingerprints"
echo "OBSERVED_FAILURE_SIGNATURES_BEGIN"
printf '%s\n' "$failure_signatures"
echo "OBSERVED_FAILURE_SIGNATURES_END"
echo "ARTIFACT_DIRECTORY=$artifact_dir"
echo "PRODUCTION_IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY_CHANGE_AUTHORIZED=NO"
echo "PRODUCTION_GENERATION_POLICY=UNCHANGED"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=CLASSIFY_PHASE_3_REPEATED_UNSEEDED_VALIDATION_RESULT"
