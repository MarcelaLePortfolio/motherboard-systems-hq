#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUTPUT="docs/phase487_operator_guidance_route_owner.txt"

{
  echo "PHASE 487 — OPERATOR GUIDANCE ROUTE OWNER TRACE"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] ROUTE / ENDPOINT REFERENCES"
  grep -RniE '/events/operator-guidance|operator-guidance|operator_guidance|operatorGuidance' \
    server server.mjs src app public/js dashboard/src \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null || true
  echo

  echo "[2] SSE SERVER PRIMITIVES"
  grep -RniE 'text/event-stream|EventSource|res\.write|writeHead|flushHeaders|setInterval|heartbeat' \
    server server.mjs src app public/js dashboard/src \
    --exclude-dir=node_modules \
    --exclude-dir=.next \
    2>/dev/null || true
  echo

  for f in \
    server.mjs \
    public/js/operatorGuidance.sse.js
  do
    if [ -f "$f" ]; then
      echo
      echo "===== FILE: $f ====="
      nl -ba "$f" | sed -n '1,260p'
    fi
  done

  while IFS= read -r f; do
    [ -f "$f" ] || continue
    echo
    echo "===== CANDIDATE FILE: $f ====="
    nl -ba "$f" | sed -n '1,260p'
  done < <(
    grep -RliE '/events/operator-guidance|operator-guidance|operator_guidance|operatorGuidance|text/event-stream|res\.write|writeHead|flushHeaders' \
      server server.mjs src app \
      --exclude-dir=node_modules \
      --exclude-dir=.next \
      2>/dev/null | sort -u
  )

  echo
  echo "TRACE COMPLETE"
} > "$OUTPUT"

echo "Generated: $OUTPUT"
