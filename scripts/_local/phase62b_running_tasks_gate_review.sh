#!/usr/bin/env bash
set -euo pipefail

SRC="docs/checkpoints/PHASE62B_RUNNING_TASKS_VALIDATION_PASS_20260316.md"
OUT="docs/checkpoints/PHASE62B_RUNNING_TASKS_GATE_REVIEW_20260316.md"

mkdir -p docs/checkpoints

if [ ! -f "$SRC" ]; then
  echo "Missing validation artifact: $SRC" >&2
  exit 1
fi

pass_count="$(grep -c 'RESULT: PASS' "$SRC" || true)"
fail_count="$(grep -c 'RESULT: FAIL' "$SRC" || true)"
skip_count="$(grep -c '^SKIP ' "$SRC" || true)"
error_count="$(grep -Ei -c 'error|syntax error|not found|failed to|npm error' "$SRC" || true)"

gate_status="PASS"
if [ "$fail_count" -gt 0 ] || [ "$error_count" -gt 0 ]; then
  gate_status="FAIL"
elif [ "$skip_count" -gt 0 ]; then
  gate_status="PARTIAL / SKIP-BOUND"
fi

{
  echo "PHASE 62B — RUNNING TASKS GATE REVIEW"
  echo "Date: 2026-03-16"
  echo
  echo "────────────────────────────────"
  echo
  echo "SOURCE"
  echo "$SRC"
  echo
  echo "────────────────────────────────"
  echo
  echo "COUNTS"
  echo "PASS: $pass_count"
  echo "FAIL: $fail_count"
  echo "SKIP: $skip_count"
  echo "ERROR-LIKE MATCHES: $error_count"
  echo
  echo "────────────────────────────────"
  echo
  echo "CLASSIFICATION"
  echo "$gate_status"
  echo
  echo "────────────────────────────────"
  echo
  echo "MATCHES — PASS"
  grep -n 'RESULT: PASS' "$SRC" || true
  echo
  echo "────────────────────────────────"
  echo
  echo "MATCHES — FAIL"
  grep -n 'RESULT: FAIL' "$SRC" || true
  echo
  echo "────────────────────────────────"
  echo
  echo "MATCHES — SKIP"
  grep -n '^SKIP ' "$SRC" || true
  echo
  echo "────────────────────────────────"
  echo
  echo "MATCHES — ERROR-LIKE"
  grep -Ein 'error|syntax error|not found|failed to|npm error' "$SRC" || true
  echo
  echo "────────────────────────────────"
  echo
  echo "SUCCESS CONDITION"
  echo "Gate status explicitly classified from validation artifact."
} > "$OUT"

printf 'Wrote %s\n' "$OUT"
sed -n '1,220p' "$OUT"

git add scripts/_local/phase62b_running_tasks_gate_review.sh "$OUT"
git commit -m "Phase 62B gate review — classify running tasks validation artifact"
git push
