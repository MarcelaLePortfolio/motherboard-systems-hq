#!/usr/bin/env bash
set -euo pipefail

REPORT="_reports/phase628-task-events-sse-check.md"

{
  echo "# Phase 628 Task Events SSE Check"
  echo
  echo "## Route probe"
  curl -i --max-time 5 http://localhost:3000/events/task-events || true
  echo
  echo "## Server route references"
  grep -RIn --include="*.js" --include="*.mjs" --include="*.ts" \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
    "events/task-events\\|/events/tasks\\|eventsRouter\\|task-events" server server.js server.mjs public/js/task-events-sse-client.js || true
} > "$REPORT"

cat "$REPORT"
