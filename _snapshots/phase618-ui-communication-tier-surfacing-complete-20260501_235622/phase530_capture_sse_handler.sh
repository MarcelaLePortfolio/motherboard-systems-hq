#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 530 — CAPTURE SSE HANDLER"
echo "───────────────────────────────"

echo ""
echo "STEP 1: Run discovery script and capture output..."
OUTPUT=$(./phase530_find_sse_handler.sh)

echo "$OUTPUT"

echo ""
echo "STEP 2: Extract candidate file paths..."
echo "$OUTPUT" | grep -Eo '^\./[^: ]+' | sort -u > .sse_candidate_files.txt || true

echo ""
echo "Candidate files:"
cat .sse_candidate_files.txt || true

echo ""
echo "STEP 3: Preview first 200 lines of each candidate (manual inspection required)..."
while read -r file; do
  echo ""
  echo "──────── FILE: $file ────────"
  sed -n '1,200p' "$file" || true
done < .sse_candidate_files.txt

echo ""
echo "NO CHANGES MADE. Identify the SINGLE SSE handler before patching."
