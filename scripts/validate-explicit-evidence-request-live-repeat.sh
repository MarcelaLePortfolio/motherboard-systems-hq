#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

passes=0
runs=3

for i in $(seq 1 "$runs"); do
  echo
  echo "=== EXPLICIT EVIDENCE LIVE RUN $i/$runs ==="

  output="$(
    npx tsx scripts/validate-support-driven-source-excerpt-live.ts 2>&1
  )"
  rc=$?

  printf '%s\n' "$output"
  echo "RUN_${i}_EXIT_CODE=$rc"

  if [[ $rc -ne 0 ]]; then
    echo "EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL"
    exit 1
  fi

  if ! grep -q \
    "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED" \
    <<<"$output"
  then
    echo "EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL"
    exit 1
  fi

  passes=$((passes + 1))
done

echo
echo "=== DETERMINATION ==="
echo "PASSED_RUNS=$passes"
echo "TOTAL_RUNS=$runs"

if [[ "$passes" -eq "$runs" ]]; then
  echo "EXPLICIT_EVIDENCE_REPEAT_VALIDATION_SUPPORTED"
else
  echo "EXPLICIT_EVIDENCE_REPEAT_VALIDATION_FAIL"
  exit 1
fi
