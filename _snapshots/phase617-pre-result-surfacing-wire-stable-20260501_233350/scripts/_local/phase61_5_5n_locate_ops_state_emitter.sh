#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT="docs/checkpoints/PHASE61_5_5N_LOCATE_OPS_STATE_EMITTER_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.5n locate ops.state emitter =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== latest trace file =="
  latest_trace="$(ls -1t docs/checkpoints/PHASE61_5_5M_TRACE_OPS_AGENT_STATE_SOURCE_*.txt 2>/dev/null | head -n 1 || true)"
  if [ -n "${latest_trace:-}" ]; then
    echo "file: $latest_trace"
    sed -n '1,220p' "$latest_trace"
  else
    echo "no phase61_5_5m trace found"
  fi
  echo

  echo "== exact emit sites for ops.state / SSE ops connected =="
  grep -RniE 'ops\\.state|SSE ops connected|lastHeartbeatAt|agents:\\{\\}|agents\\s*:\\s*\\{\\}|event:\\s*ops\\.state' server public server.mjs public/js 2>/dev/null || true
  echo

  echo "== event-stream response helpers / writers =="
  grep -RniE 'res\\.write|writeHead|text/event-stream|EventSource|event: hello|event: heartbeat|kind":"ops"|kind: "ops"|kind:\x27ops\x27' server public server.mjs public/js 2>/dev/null || true
  echo

  echo "== likely source files =="
  find server -maxdepth 4 -type f | sort | grep -Ei 'ops|sse|status|broadcast|heartbeat|orchestrator' || true
  echo

  echo "== top candidate file snippets =="
  for f in \
    server/routes/ops-sse.mjs \
    server/routes/ops-status.mjs \
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
} > "$OUT"

echo "$OUT"
