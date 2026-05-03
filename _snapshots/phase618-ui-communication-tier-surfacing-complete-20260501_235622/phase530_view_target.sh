#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 530 — VIEW TARGET SSE HANDLER"
echo "───────────────────────────────────"

FILE="./server/routes/task-events-sse.mjs"

if [ ! -f "$FILE" ]; then
  echo "ERROR: Target file not found: $FILE"
  exit 1
fi

echo ""
echo "Displaying full file for inspection:"
echo "──────── $FILE ────────"
sed -n '1,300p' "$FILE"

echo ""
echo "NO CHANGES MADE. Review handler before patching."
