#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT="docs/checkpoints/PHASE61_5_5Z_PROVE_AGENT_STATUS_ROUTE_UPDATES_OPS_SNAPSHOT_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.5z prove agent-status route updates ops snapshot =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== POST /api/ops/agent-status =="
  curl -sS --max-time 5 -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Matilda","status":"running","meta":{"source":"phase61_5_5z_probe"}}'
  echo
  curl -sS --max-time 5 -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Cade","status":"queued","meta":{"source":"phase61_5_5z_probe"}}'
  echo
  curl -sS --max-time 5 -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Effie","status":"ready","meta":{"source":"phase61_5_5z_probe"}}'
  echo
  curl -sS --max-time 5 -X POST http://127.0.0.1:8080/api/ops/agent-status \
    -H 'Content-Type: application/json' \
    -d '{"agent":"Atlas","status":"ready","meta":{"source":"phase61_5_5z_probe"}}'
  echo
  echo

  echo "== bounded /events/ops sample after posts =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
  echo
  echo

  echo "== extracted agent-bearing lines =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops 2>/dev/null \
    | grep -nE 'ops.state|Matilda|Cade|Effie|Atlas|agents|status|running|queued|ready' || true
  echo
} > "$OUT"

echo "$OUT"
sed -n '1,260p' "$OUT"
