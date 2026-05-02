#!/bin/bash
set -euo pipefail

INPUT="PHASE619_EXECUTION_GUIDANCE_CANDIDATES.txt"
OUT="PHASE619_EXECUTION_GUIDANCE_SUMMARY.txt"

echo "🔍 Summarizing execution guidance candidates..."

if [ ! -f "$INPUT" ]; then
  echo "❌ Missing $INPUT"
  exit 1
fi

{
  echo "PHASE 619 — EXECUTION GUIDANCE SUMMARY"
  echo ""
  echo "Top candidate signals (filtered):"
  echo ""

  grep -Ei "task_execution_interpreter|retry_execution_router|requeue|retry|delegate-task|follow|next action" "$INPUT" | head -n 120 || true

  echo ""
  echo "────────────────────────────────"
  echo ""
  echo "Key files detected:"
  grep -E "^===== " "$INPUT" | head -n 20 || true

} > "$OUT"

echo "✅ Wrote summary → $OUT"
