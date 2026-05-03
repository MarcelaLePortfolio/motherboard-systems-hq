#!/bin/bash
set -euo pipefail

OUT="PHASE619_EXECUTION_GUIDANCE_CANDIDATES.txt"

cat > "$OUT" << 'REPORT'
PHASE 619 — EXECUTION GUIDANCE CANDIDATE AUDIT

Goal:
Find existing pieces for:
- outcome interpretation
- retry routing
- follow-up decisioning
- task creation through existing pipeline

Do not patch yet.
Do not invent a new execution path.

────────────────────────────────

REPORT

{
  echo ""
  echo "=== SEARCH: execution interpretation / routing / retry ==="
  grep -RIn "interpret.*execution\|execution.*interpret\|route.*execution\|execution.*route\|retry\|requeue\|follow-up\|followup\|next action\|next_action" server public/js src docs PHASE* \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=.next \
    --exclude-dir=_snapshots \
    2>/dev/null || true

  echo ""
  echo "=== KEY FILES: worker interpretation / retry router ==="
  for file in \
    server/worker/task_execution_interpreter.mjs \
    server/retry_execution_router.js \
    server/routes/api-tasks-postgres.mjs \
    server/routes/api-tasks-mutations.mjs \
    server/tasks-mutations.mjs \
    public/js/phase537_execution_inspector_retry.js \
    public/js/phase535_execution_inspector_requeue.js \
    public/js/phase538_execution_inspector_retry_strategies.js
  do
    if [ -f "$file" ]; then
      echo ""
      echo "===== $file ====="
      sed -n '1,220p' "$file"
    fi
  done
} >> "$OUT"

echo "✅ Wrote execution guidance candidate audit to $OUT"
