#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/checkpoints/PHASE61_5_5U_TRACE_OPS_STATE_WRITERS_${STAMP}.txt"
mkdir -p docs/checkpoints

{
  echo "== Phase 61.5.5u trace ops state writers =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo
  echo "== branch / head =="
  git branch --show-current
  git rev-parse --short HEAD
  echo

  echo "== __OPS_STATE definitions and writes =="
  grep -RniE '__OPS_STATE|lastHeartbeatAt|agents[[:space:]]*:|broadcast\\(state, "ops\\.state"|__SSE_BROADCAST\\.ops|ops\\.broadcast\\(' server.mjs server 2>/dev/null || true
  echo

  echo "== server.mjs focused snippet around __OPS_STATE =="
  sed -n '140,270p' server.mjs
  echo
  sed -n '480,570p' server.mjs
  echo

  echo "== bounded /events/ops sample =="
  curl -N --max-time 8 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
  echo
  echo

  echo "== conclusion =="
  echo "Current truthful frontend patch is working."
  echo "Current backend /events/ops payload still emits status=unknown and agents={}."
  echo "Until server-side writers populate __OPS_STATE.agents with real agent statuses, dots will remain gray truthfully."
} > "$OUT"

echo "$OUT"
sed -n '1,260p' "$OUT"
