#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/checkpoints/PHASE61_5_5V_TRACE_AGENT_STATUS_PRODUCERS_${STAMP}.txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.5v trace agent status producers =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== repo references to /api/ops/agent-status and /api/ops/heartbeat =="
  grep -RniE '/api/ops/agent-status|/api/ops/heartbeat|ops/agent-status|ops/heartbeat|__OPS_STATE\.agents|ops\.heartbeat|ops\.agent-status' \
    server public scripts . 2>/dev/null || true
  echo

  echo "== focused server snippet for agent-status route =="
  sed -n '560,660p' server.mjs
  echo

  echo "== live proof the route mutates ops state =="
  curl -sS -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Matilda","status":"running","meta":{"source":"phase61_5_5v_probe"}}'
  echo
  curl -sS -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Cade","status":"queued","meta":{"source":"phase61_5_5v_probe"}}'
  echo
  curl -sS -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Effie","status":"ready","meta":{"source":"phase61_5_5v_probe"}}'
  echo
  curl -sS -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Atlas","status":"ready","meta":{"source":"phase61_5_5v_probe"}}'
  echo
  echo

  echo "== bounded /events/ops after manual status posts =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
  echo
  echo

  echo "== conclusion =="
  echo "If the bounded sample now includes populated agents, frontend is healthy and the missing piece is producer wiring."
  echo "If it still does not, the backend snapshot/broadcast path is the next controlled fix."
} > "$OUT"

echo "$OUT"
sed -n '1,260p' "$OUT"
