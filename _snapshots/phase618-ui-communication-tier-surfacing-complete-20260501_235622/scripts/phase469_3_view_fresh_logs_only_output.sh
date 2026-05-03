#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="docs/phase469_2_verify_with_fresh_logs_only.txt"

echo "PHASE 469.3 — VIEW FRESH LOGS ONLY OUTPUT"
echo "========================================="
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

echo "DONE — Copy the CLASSIFICATION line and any fresh error lines"
