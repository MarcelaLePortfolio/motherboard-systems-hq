#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

OUT="docs/checkpoints/PHASE61_5_5O_EXTRACT_OPS_FINDINGS_$(date +%Y%m%d_%H%M%S).txt"
mkdir -p docs/checkpoints

LATEST_N="$(ls -1t docs/checkpoints/PHASE61_5_5N_LOCATE_OPS_STATE_EMITTER_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_I="$(ls -1t docs/checkpoints/PHASE61_5_5I_OPS_EVENT_SCHEMA_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_M="$(ls -1t docs/checkpoints/PHASE61_5_5M_TRACE_OPS_AGENT_STATE_SOURCE_*.txt 2>/dev/null | head -n 1 || true)"

{
  echo "== Phase 61.5.5o extracted ops findings =="
  echo "timestamp: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo

  echo "== latest source artifacts =="
  echo "N: ${LATEST_N:-none}"
  echo "I: ${LATEST_I:-none}"
  echo "M: ${LATEST_M:-none}"
  echo

  for f in "$LATEST_I" "$LATEST_M" "$LATEST_N"; do
    [ -n "${f:-}" ] || continue
    [ -f "$f" ] || continue

    echo "===== FILE: $f ====="
    echo

    echo "-- ops events --"
    grep -nE 'event: hello|event: ops\.state|event: heartbeat|SSE ops connected|lastHeartbeatAt|agents|status' "$f" || true
    echo

    echo "-- likely server emitters --"
    grep -nE 'ops\.state|SSE ops connected|lastHeartbeatAt|agents\s*:|text/event-stream|event: hello|event: heartbeat|res\.write' "$f" || true
    echo

    echo "-- candidate file headers around matches --"
    awk '
      /^--- / { file=$0 }
      /ops\.state|SSE ops connected|lastHeartbeatAt|agents\s*:|text\/event-stream|event: hello|event: heartbeat|res\.write/ {
        print file
        print $0
        print ""
      }
    ' "$f" || true
    echo
  done

  echo "== current truthful frontend status source =="
  sed -n '1,220p' public/js/agent-status-row.js
  echo

  echo "== current live /events/ops quick sample =="
  curl -N --max-time 5 -H 'Accept: text/event-stream' http://127.0.0.1:8080/events/ops || true
  echo
} > "$OUT"

echo "$OUT"
