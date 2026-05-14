
#!/bin/bash

set -e

echo "===== PHASE 719 VALIDATE IFRAME RENDERER V2 ====="

DASHBOARD_CONTAINER="$(docker ps --format '{{.Names}}' | grep -E 'dashboard' | head -1 || true)"

WORKER_CONTAINER="$(docker ps --format '{{.Names}}' | grep -E 'worker' | head -1 || true)"

echo ""

echo "[1] Git status"

git status --short

echo ""

echo "[2] Latest commits"

git log --oneline --decorate -6

echo ""

echo "[3] Verify renderer symbols"

grep -n "phase719RenderArtifactIframePreview\|phase719RenderMarkdownArtifactPreview\|sandbox=\"\"" public/js/phase530_visible_panels_bridge.js

echo ""

echo "[4] Verify Docker containers"

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "[5] Verify dashboard root"

curl -sS http://localhost:3000/ | head -20

echo ""

echo "[6] Verify tasks API"

curl -sS http://localhost:3000/api/tasks | head -40

echo ""

echo "[7] Verify artifact preview route using latest artifact task"

TASK_ID="$(curl -sS http://localhost:3000/api/tasks | python3 -c 'import sys,json; data=json.load(sys.stdin); print(next((t.get("task_id") for t in data.get("tasks",[]) if t.get("artifact")), ""))')"

if [ -n "$TASK_ID" ]; then

  echo "Using task: $TASK_ID"

  curl -sS "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -40

else

  echo "No artifact-backed task found."

fi

echo ""

echo "[8] Verify SSE endpoint headers"

curl -I -sS http://localhost:3000/events/task-events | head -20 || true

echo ""

echo "[9] Check dashboard logs for recent errors"

if [ -n "$DASHBOARD_CONTAINER" ]; then

  docker logs --tail 120 "$DASHBOARD_CONTAINER" 2>&1 | grep -Ei "error|exception|failed|syntax|typeerror|referenceerror" || true

else

  echo "No dashboard container found."

fi

echo ""

echo "[10] Check worker logs for recent errors"

if [ -n "$WORKER_CONTAINER" ]; then

  docker logs --tail 120 "$WORKER_CONTAINER" 2>&1 | grep -Ei "error|exception|failed|syntax|typeerror|referenceerror" || true

else

  echo "No worker container found."

fi

echo ""

echo "===== VALIDATION COMPLETE ====="

echo "Open localhost:3000, click a completed task Preview pill, and confirm the artifact appears inside the isolated iframe modal."

