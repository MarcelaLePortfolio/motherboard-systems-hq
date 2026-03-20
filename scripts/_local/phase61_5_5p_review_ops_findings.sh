#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

LATEST_O="$(ls -1t docs/checkpoints/PHASE61_5_5O_EXTRACT_OPS_FINDINGS_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_N="$(ls -1t docs/checkpoints/PHASE61_5_5N_LOCATE_OPS_STATE_EMITTER_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_M="$(ls -1t docs/checkpoints/PHASE61_5_5M_TRACE_OPS_AGENT_STATE_SOURCE_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_I="$(ls -1t docs/checkpoints/PHASE61_5_5I_OPS_EVENT_SCHEMA_*.txt 2>/dev/null | head -n 1 || true)"

echo "== latest checkpoint files =="
echo "O: ${LATEST_O:-none}"
echo "N: ${LATEST_N:-none}"
echo "M: ${LATEST_M:-none}"
echo "I: ${LATEST_I:-none}"
echo

for f in "$LATEST_O" "$LATEST_N" "$LATEST_M" "$LATEST_I"; do
  [ -n "${f:-}" ] || continue
  [ -f "$f" ] || continue
  echo "===== $f ====="
  sed -n '1,220p' "$f"
  echo
done

echo "== exact ops emitter search =="
grep -RniE 'ops\.state|SSE ops connected|lastHeartbeatAt|agents:\{\}|agents\s*:\s*\{|event: hello|event: heartbeat|text/event-stream|res\.write' \
  server public server.mjs public/js 2>/dev/null || true
echo

echo "== high-probability source files =="
for f in \
  server/routes/ops-sse.mjs \
  server/routes/dashboard-broadcast.mjs \
  server/routes/dashboard-status.mjs \
  server/orchestrator_state_route.mjs \
  server/task_events_emit.mjs \
  public/js/dashboard-broadcast.js \
  public/js/dashboard-status.js \
  public/js/agent-status-row.js
do
  if [ -f "$f" ]; then
    echo "--- $f ---"
    sed -n '1,260p' "$f"
    echo
  fi
done
