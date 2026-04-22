#!/usr/bin/env bash

set -euo pipefail

echo "Scanning for SSE endpoints and duplicate emitters..."

echo ""
echo "=== text/event-stream headers ==="
rg -n --glob '!*node_modules*' --glob '!*dist*' "text/event-stream" . || true

echo ""
echo "=== res.write SSE usage ==="
rg -n --glob '!*node_modules*' --glob '!*dist*' "res\.write\\(|event:|data:" . || true

echo ""
echo "=== potential duplicate SSE servers ==="
rg -n --glob '!*node_modules*' --glob '!*dist*' "reflections-sse|ops-sse|task-events|events.ts|EventSource" . || true

echo ""
echo "=== summary counts ==="
echo "event-stream count:"
rg -c "text/event-stream" . || true

echo "Done."
