#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 539 — LOGS RENDERER DIAGNOSTIC"
echo "────────────────────────────────────"

echo ""
echo "1. Find visible log labels / containers in root HTML:"
grep -n "Execution Activity\|Task Activity\|Recent Tasks\|Execution Trail\|mb-task-events\|task-events" public/index.html || true

echo ""
echo "2. Find JS files that render or mutate task/event logs:"
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  "mb-task-events\|Execution Trail\|Task Activity\|task.event\|task-events-feed\|recent history\|Recent Tasks\|appendChild.*row\|prepend(row)" public/js || true

echo ""
echo "3. Served root script references:"
curl -s http://localhost:8080/ | grep -n "<script\|task-events\|phase61\|phase457\|dashboard-bundle" || true

echo ""
echo "DIAGNOSIS:"
echo "The tab label was static HTML. The unchanged logs are likely rendered by a different JS file than task-events-sse-client.js."
echo "Use this output to identify the active renderer before patching."
