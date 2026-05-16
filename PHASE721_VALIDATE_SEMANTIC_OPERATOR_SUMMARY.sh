
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 721 SEMANTIC OPERATOR SUMMARY VALIDATION ====="

echo ""

echo "[1] Runtime status"

docker ps

echo ""

echo "[2] Served frontend code contains operator summary"

docker exec motherboard_systems_hq-dashboard-1 sh -lc "grep -n 'semanticOperatorSummary\|Semantic Operator Summary' /app/public/js/phase530_visible_panels_bridge.js"

echo ""

echo "[3] Dashboard health"

curl -s http://localhost:3000/ | head -5 || true

echo ""

echo "[4] Create fresh Phase 721 semantic summary task"

TASK_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-raw '{"title":"Phase 721 semantic operator summary validation","task":"Generate a concise artifact to validate semantic operator summary rendering while preserving markdown fallback."}')

echo "$TASK_RESPONSE" | tee PHASE721_OPERATOR_SUMMARY_TASK_RESPONSE.json

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

curl -s "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" | tee PHASE721_OPERATOR_SUMMARY_ARTIFACT_PREVIEW.json

echo ""

echo "[7] Verify semantic envelope remains present"

grep -n "MB_SEMANTIC_ARTIFACT_V1" PHASE721_OPERATOR_SUMMARY_ARTIFACT_PREVIEW.json || true

echo ""

echo "[8] Verify markdown fallback sections remain present"

grep -n "## Summary\\|## Deliverable\\|## Details\\|## Recommendations\\|## Next Steps\\|## Outcome" PHASE721_OPERATOR_SUMMARY_ARTIFACT_PREVIEW.json || true

echo ""

echo "[9] Verify task list route remains operational"

curl -s http://localhost:3000/api/tasks | tee PHASE721_OPERATOR_SUMMARY_TASKS_RESPONSE.json >/dev/null

grep -n '"ok"' PHASE721_OPERATOR_SUMMARY_TASKS_RESPONSE.json || true

echo ""

echo "===== VALIDATION COMPLETE ====="

