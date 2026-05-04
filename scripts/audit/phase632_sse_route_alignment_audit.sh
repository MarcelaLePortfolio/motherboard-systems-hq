#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 632 SSE Route Alignment Audit ==="
echo
echo "Registered event/guidance routes:"
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "app\.get\(\"/events|app\.use\(\"/events|/events/task-events|/events/tasks|/events/operator-guidance|/api/guidance|operator-guidance|api/guidance" \
  server server.mjs public/js public/index.html 2>/dev/null | sed -n '1,220p'

echo
echo "Probe active endpoints:"
for path in /events/task-events /events/tasks /events/operator-guidance /api/guidance /api/tasks; do
  echo
  echo "--- $path ---"
  curl -sS -N --max-time 4 -H "Accept: text/event-stream" "http://localhost:3000$path" || true
done
