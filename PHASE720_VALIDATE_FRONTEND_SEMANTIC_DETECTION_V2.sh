
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 720 FRONTEND SEMANTIC DETECTION V2 VALIDATION ====="

echo ""

echo "[1] Runtime status"

docker ps

echo ""

echo "[2] Dashboard health"

curl -s http://localhost:3000/ | head -5 || true

echo ""

echo "[3] Create fresh semantic artifact task"

TASK_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-raw '{"title":"Phase 720 frontend semantic detection validation","task":"Generate a concise artifact to validate frontend detection of MB_SEMANTIC_ARTIFACT_V1 while preserving markdown fallback."}')

echo "$TASK_RESPONSE" | tee PHASE720_FRONTEND_DETECTION_TASK_RESPONSE.json

TASK_ID=$(echo "$TASK_RESPONSE" | jq -r '.task_id // .id // empty')

if [ -z "$TASK_ID" ]; then

  echo "FAILED: could not resolve task id"

  exit 1

fi

echo ""

echo "[4] Waiting for completion"

sleep 15

echo ""

echo "[5] Fetch fresh artifact preview JSON"

curl -s "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" | tee PHASE720_FRONTEND_DETECTION_ARTIFACT_PREVIEW.json

echo ""

echo "[6] Verify worker semantic envelope still present"

grep -n "MB_SEMANTIC_ARTIFACT_V1" PHASE720_FRONTEND_DETECTION_ARTIFACT_PREVIEW.json || true

echo ""

echo "[7] Verify frontend detection code served in dashboard container"

docker exec motherboard_systems_hq-dashboard-1 sh -lc "grep -n 'phase720ExtractSemanticEnvelope\|semantic v' /app/public/js/phase530_visible_panels_bridge.js"

echo ""

echo "[8] Verify route still serves task list"

curl -s http://localhost:3000/api/tasks | tee PHASE720_FRONTEND_DETECTION_TASKS_RESPONSE.json >/dev/null

grep -n '"ok"' PHASE720_FRONTEND_DETECTION_TASKS_RESPONSE.json || true

echo ""

echo "===== VALIDATION COMPLETE ====="

