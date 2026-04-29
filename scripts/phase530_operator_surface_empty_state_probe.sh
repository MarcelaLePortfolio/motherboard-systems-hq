#!/usr/bin/env bash
set -euo pipefail

echo "=============================================="
echo "PHASE 530 — OPERATOR SURFACE EMPTY STATE PROBE"
echo "=============================================="

BASE_URL="http://localhost:8080"

echo ""
echo "1) Checking dashboard root..."
curl -sS -I "$BASE_URL/" || true

echo ""
echo "2) Checking likely agent/task API endpoints..."
for endpoint in \
  "/api/agents" \
  "/api/agent-pool" \
  "/api/tasks" \
  "/api/task-events" \
  "/api/health"
do
  echo ""
  echo "---- $endpoint ----"
  curl -sS "$BASE_URL$endpoint" || true
  echo ""
done

echo ""
echo "3) Checking SSE endpoint for visible output..."
curl -N --max-time 5 "$BASE_URL/events/tasks" || true

echo ""
echo "4) Locating Agent Pool implementation..."
grep -RIn "Agent Pool\|agent pool\|AgentPool\|agent-pool\|agents" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build || true

echo ""
echo "5) Locating Execution Inspector implementation..."
grep -RIn "Execution Inspector\|execution inspector\|ExecutionInspector\|execution-inspector" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build || true

echo ""
echo "6) Locating shared operator surface fetch/subscription code..."
grep -RIn "fetch(.*api\|EventSource\|/events/tasks\|task_events\|task-events\|Recent Tasks\|Execution Trail" . \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  --exclude-dir=build || true

echo ""
echo "=============================================="
echo "INTERPRETATION"
echo "=============================================="
echo "- Execution Inspector empty + Agent Pool empty likely means shared operator data hydration broke."
echo "- If API endpoints return data but UI is empty, fix frontend fetch/render wiring."
echo "- If API endpoints are empty or 404, fix backend route registration or data source."
echo "- If SSE is silent, fix stream/emission after confirming base API hydration."
