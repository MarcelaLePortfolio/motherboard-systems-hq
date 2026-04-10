#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/phase469_0_fresh_tasks_route_verification_after_schema_alignment.txt"

echo "PHASE 469.1 — VIEW FRESH VERIFICATION OUTPUT"
echo "============================================"
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

echo "STEP 2 — Print first 260 lines"
sed -n '1,260p' "$FILE"
echo

echo "STEP 3 — Print tail (last 120 lines)"
tail -n 120 "$FILE" 2>/dev/null || true
echo

echo "DONE — review CLASSIFICATION and any remaining error lines"
