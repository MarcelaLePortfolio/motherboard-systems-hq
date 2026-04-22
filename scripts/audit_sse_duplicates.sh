#!/usr/bin/env bash

set -e

echo "Scanning for SSE endpoints and duplicate emitters..."

echo ""
echo "=== text/event-stream headers ==="
rg -n "text/event-stream" . || true

echo ""
echo "=== res.write SSE usage ==="
rg -n "res\.write\\(|event:|data:" . || true

echo ""
echo "=== potential duplicate SSE servers ==="
rg -n "reflections-sse|ops-sse|task-events|events.ts|EventSource" . || true

echo ""
echo "Done."
