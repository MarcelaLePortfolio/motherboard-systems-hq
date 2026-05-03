#!/usr/bin/env bash
set -euo pipefail

TARGET="routes/diagnostics/systemHealth.ts"
OUT="docs/phase464_x_payload_trace.txt"

if [ ! -f "$TARGET" ]; then
  echo "ERROR: expected file not found: $TARGET"
  exit 1
fi

{
  echo "PHASE 464.X — SYSTEM HEALTH PAYLOAD TRACE"
  echo "========================================="
  echo
  echo "TARGET FILE: $TARGET"
  echo

  echo "STEP 1 — Locate response construction"
  rg -n 'res\.json|res\.send' "$TARGET" || true
  echo

  echo "STEP 2 — Locate SYSTEM_HEALTH references"
  rg -n 'SYSTEM_HEALTH|systemHealth|guidance|summary|operator|status' "$TARGET" || true
  echo

  echo "STEP 3 — Extract surrounding logic (focused)"
  echo "--------------------------------------------"
  rg -n -C 10 'res\.json|res\.send' "$TARGET" || true
  echo

  echo "STEP 4 — Detect possible loop or array construction"
  rg -n 'map\(|forEach|while|push\(|repeat|join\(' "$TARGET" || true
  echo

  echo "STEP 5 — Top 200 lines for context"
  sed -n '1,200p' "$TARGET"
  echo

  echo "DECISION TARGET"
  echo "- Identify if SYSTEM_HEALTH is:"
  echo "  • hardcoded"
  echo "  • appended in a loop"
  echo "  • derived from an array or aggregation"
  echo "- Next step: isolate EXACT line causing repetition"
} > "$OUT"

echo "Wrote $OUT"
echo "OPEN NEXT: $OUT"

