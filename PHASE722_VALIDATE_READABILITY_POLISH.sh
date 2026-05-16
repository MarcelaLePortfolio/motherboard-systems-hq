
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 722 READABILITY POLISH VALIDATION ====="

echo ""

echo "[1] Runtime status"

docker ps

echo ""

echo "[2] Served frontend code contains Phase 722 polish"

docker exec motherboard_systems_hq-dashboard-1 sh -lc "grep -n 'phase722IsDuplicateSemanticText\|Semantic Insights' /app/public/js/phase530_visible_panels_bridge.js"

echo ""

echo "[3] Dashboard health"

curl -s http://localhost:3000/ | head -5 || true

echo ""

echo "[4] Create fresh Phase 722 readability validation task"

TASK_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-raw '{"title":"Phase 722 readability polish validation","task":"Generate a concise semantic artifact to validate readability polish, duplicate reduction, semantic insights, and markdown fallback preservation."}')

echo "$TASK_RESPONSE" | tee PHASE722_READABILITY_TASK_RESPONSE.json

TASK_ID=$(echo "$TASK_RESPONSE" | jq -r '.task_id // .id // empty')

if [ -z "$TASK_ID" ]; then

  echo "FAILED: could not resolve task id"

  exit 1

fi

echo ""

echo "[5] Waiting for completion"

sleep 15

echo ""

echo "[6] Fetch artifact preview"

curl -s "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" | tee PHASE722_READABILITY_ARTIFACT_PREVIEW.json

echo ""

echo "[7] Verify semantic envelope remains present"

grep -n "MB_SEMANTIC_ARTIFACT_V1" PHASE722_READABILITY_ARTIFACT_PREVIEW.json || true

echo ""

echo "[8] Verify markdown fallback sections remain present"

grep -n "## Summary\\|## Deliverable\\|## Details\\|## Recommendations\\|## Next Steps\\|## Outcome" PHASE722_READABILITY_ARTIFACT_PREVIEW.json || true

echo ""

echo "[9] Verify task list route remains operational"

curl -s http://localhost:3000/api/tasks | tee PHASE722_READABILITY_TASKS_RESPONSE.json >/dev/null

grep -n '"ok"' PHASE722_READABILITY_TASKS_RESPONSE.json || true

echo ""

echo "===== VALIDATION COMPLETE ====="

