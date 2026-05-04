#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 632 Operator Guidance Audit ==="
echo
echo "Search guidance/operator UI wiring:"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "Operator Guidance|operator guidance|guidance|communicationResult|outcome_preview|explanation_preview|/api/tasks|/events/tasks|EventSource" \
  public server server.mjs scripts 2>/dev/null | sed -n '1,240p'

echo
echo "API tasks snapshot:"
curl -sS "http://localhost:3000/api/tasks?limit=10" | jq . || curl -sS "http://localhost:3000/api/tasks?limit=10"

echo
echo "SSE tasks sample:"
curl -sS -N --max-time 6 -H "Accept: text/event-stream" "http://localhost:3000/events/tasks" || true
