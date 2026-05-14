
#!/bin/bash

set -e

echo "===== PHASE 719 VALIDATE IFRAME RENDERER ====="

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

echo "[7] Verify SSE endpoint headers"

curl -I -sS http://localhost:3000/events/task-events | head -20 || true

echo ""

echo "[8] Check dashboard logs for recent errors"

docker logs --tail 120 motherboard_dashboard 2>&1 | grep -Ei "error|exception|failed|syntax|typeerror|referenceerror" || true

echo ""

echo "[9] Check worker logs for recent errors"

docker logs --tail 120 motherboard_worker 2>&1 | grep -Ei "error|exception|failed|syntax|typeerror|referenceerror" || true

echo ""

echo "===== VALIDATION COMPLETE ====="

echo "Open localhost:3000, click a completed task Preview pill, and confirm the artifact appears inside the isolated iframe modal."

