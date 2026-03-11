#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/checkpoints/PHASE61_5_6C_TRACE_PHASE34_WORKER_HEARTBEAT_PATH_${STAMP}.txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.6c trace phase34 worker heartbeat path =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== current conclusion baseline =="
  echo "Frontend ops.state handling is healthy."
  echo "Backend agent-status route works when called."
  echo "Phase 61.5.6b showed no real producer calls in runtime files."
  echo "This pass inspects whether phase34 worker heartbeat is DB-only or HTTP-wired."
  echo

  echo "== focused worker snippet =="
  sed -n '1,240p' server/worker/phase26_task_worker.mjs
  echo
  sed -n '240,420p' server/worker/phase26_task_worker.mjs
  echo

  echo "== worker-side network call search =="
  grep -nE 'fetch\(|axios|http://|https://|/api/ops/heartbeat|/api/ops/agent-status|ops\.heartbeat|ops\.state|heartbeat.*POST|agent-status.*POST' \
    server/worker/phase26_task_worker.mjs || true
  echo

  echo "== phase34 sql files =="
  for f in \
    server/worker/phase34_heartbeat.sql \
    server/worker/phase34_heartbeat_pg.sql \
    server/worker/phase34_reclaim.sql \
    server/worker/phase34_reclaim_pg.sql
  do
    if [ -f "$f" ]; then
      echo "--- $f ---"
      sed -n '1,220p' "$f"
      echo
    fi
  done

  echo "== conclusion =="
  echo "If worker file has no HTTP producer usage and phase34 is SQL-only, producer wiring is absent in live runtime."
  echo "Next step would be a controlled no-fix-forward hand-off stating the missing piece is explicit producer wiring into /api/ops/agent-status or equivalent snapshot broadcaster."
} > "$OUT"

echo "$OUT"
sed -n '1,260p' "$OUT"
