#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/phase468_9_extract_exact_tasks_query_and_replay.txt"

echo "PHASE 468.9 — VIEW EXTRACT OUTPUT"
echo "================================="
echo
echo "SOURCE FILE: $FILE"
echo

echo "STEP 1 — Verify file exists"
if [ -f "$FILE" ]; then
  echo "OK: file found"
else
  echo "FAIL: file not found"
  exit 1
fi
echo

echo "STEP 2 — Print first 300 lines (most important)"
sed -n '1,300p' "$FILE"
echo

echo "STEP 3 — Print tail (last 120 lines)"
tail -n 120 "$FILE" 2>/dev/null || true
echo

echo "DONE — Copy this output into ChatGPT"
