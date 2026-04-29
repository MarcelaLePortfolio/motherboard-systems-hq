#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo "PHASE 530 — SSE PIPELINE PROBE"
echo "=============================="

BASE_URL="http://localhost:8080"

echo ""
echo "1) Checking SSE endpoint connectivity..."
curl -N --max-time 5 "$BASE_URL/events/tasks" || true

echo ""
echo "2) Checking if eventBus is defined in server..."
grep -RIn "eventBus" server || echo "⚠️ eventBus not found in server code"

echo ""
echo "3) Checking worker for task_event emissions..."
grep -RIn "task_event" server/worker || echo "⚠️ No task_event emission found in worker"

echo ""
echo "4) Checking UI subscription to SSE..."
grep -RIn "/events/tasks" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next || echo "⚠️ UI not subscribing to SSE"

echo ""
echo "5) Checking for Execution Inspector component..."
grep -RIn "Execution Inspector\|executionInspector\|execution-inspector" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next || echo "⚠️ Execution Inspector component not found"

echo ""
echo "=============================="
echo "INTERPRETATION GUIDE"
echo "=============================="
echo "- If step 1 shows NOTHING → SSE route broken"
echo "- If step 2 missing → event bus not wired"
echo "- If step 3 missing → worker not emitting events"
echo "- If step 4 missing → UI not listening"
echo "- If all pass → issue is UI rendering logic"
echo ""
echo "Run this BEFORE making any further changes."
