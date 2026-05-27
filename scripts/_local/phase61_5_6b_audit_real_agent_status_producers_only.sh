#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/checkpoints/PHASE61_5_6B_AUDIT_REAL_AGENT_STATUS_PRODUCERS_ONLY_${STAMP}.txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.6b audit real agent status producers only =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== proof already established =="
  echo "Frontend named ops.state handling is healthy."
  echo "Backend /api/ops/agent-status mutates __OPS_STATE and broadcasts populated ops.state."
  echo "This audit intentionally excludes docs/checkpoints and probe scripts to avoid recursive noise."
  echo

  echo "== real repo references (server/public only) =="
  grep -RniE '/api/ops/agent-status|/api/ops/heartbeat|ops/agent-status|ops/heartbeat|__OPS_STATE\.agents|ops\.heartbeat|ops\.agent-status' server public 2>/dev/null || true
  echo

  echo "== focused known runtime files =="
  for f in \
    server.mjs \
    server/worker/phase26_task_worker.mjs \
    server/tasks-mutations.mjs \
    server/routes/api-tasks-postgres.mjs \
    server/task_events_emit.mjs
  do
    if [ -f "$f" ]; then
      echo "--- $f ---"
      grep -nE '/api/ops/agent-status|/api/ops/heartbeat|heartbeat|agent-status|__OPS_STATE|ops\.heartbeat|ops\.state|fetch\(' "$f" || true
      echo
    fi
  done

  echo "== conclusion =="
  echo "If output shows only server.mjs route definitions and no caller-side fetch/post usage elsewhere, producer wiring is missing."
  echo "If output shows caller-side usage, inspect that runtime path next without changing code yet."
} > "$OUT"

echo "$OUT"
sed -n '1,220p' "$OUT"
