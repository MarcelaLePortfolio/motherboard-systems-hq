#!/usr/bin/env bash
set -euo pipefail

TARGET="routes/diagnostics/systemHealth.ts"
OUT="docs/phase464_x_repetition_isolation.txt"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: expected file not found: $TARGET"
  exit 1
fi

{
  echo "PHASE 464.X — EXACT REPETITION ISOLATION"
  echo "========================================"
  echo
  echo "TARGET FILE: $TARGET"
  echo

  echo "STEP 1 — Find SYSTEM_HEALTH string usage"
  rg -n 'SYSTEM_HEALTH' "$TARGET" || true
  echo

  echo "STEP 2 — Expand around each hit (critical)"
  echo "------------------------------------------"
  rg -n -C 15 'SYSTEM_HEALTH' "$TARGET" || true
  echo

  echo "STEP 3 — Trace guidance/summary assembly"
  rg -n -C 10 'guidance|summary|situationSummary' "$TARGET" || true
  echo

  echo "STEP 4 — Detect array aggregation patterns"
  rg -n -C 5 'push\(|map\(|join\(|forEach' "$TARGET" || true
  echo

  echo "STEP 5 — Highlight possible repeated payload construction"
  rg -n -C 5 'return|res\.json|res\.send' "$TARGET" || true
  echo

  echo "DECISION TARGET"
  echo "- Identify EXACT line where SYSTEM_HEALTH is:"
  echo "  • pushed repeatedly into an array"
  echo "  • concatenated into a string"
  echo "  • duplicated inside a loop"
  echo
  echo "- NEXT STEP:"
  echo "  We will modify ONLY that exact construction point"
  echo "  (no broad edits, no guessing)"
} > "$OUT"

echo "Wrote $OUT"
echo "OPEN NEXT: $OUT"

