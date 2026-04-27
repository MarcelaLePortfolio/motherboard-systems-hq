#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 530 — FIND SSE HANDLER"
echo "────────────────────────────"

echo ""
echo "Searching for /events/tasks, text/event-stream, and EventSource references..."
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --exclude-dir=build \
  "/events/tasks\|text/event-stream\|EventSource" . || true

echo ""
echo "No files changed. Review output before patching."
