
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 720 FRESH SEMANTIC ENVELOPE VALIDATION ====="

TASK_RESPONSE=$(curl -s -X POST "http://localhost:3000/api/tasks/create" -H "Content-Type: application/json" --data-raw '{"title":"Phase 720 fresh semantic envelope validation","task":"Generate a concise artifact that validates the new MB_SEMANTIC_ARTIFACT_V1 envelope while preserving markdown preview sections."}')

echo "$TASK_RESPONSE" | tee PHASE720_FRESH_TASK_RESPONSE.json

TASK_ID=$(echo "$TASK_RESPONSE" | jq -r '.task_id // .id // empty')

if [ -z "$TASK_ID" ]; then

  echo "FAILED: could not resolve task id"

  exit 1

fi

echo "Created task: $TASK_ID"

sleep 15

curl -s "http://localhost:3000/api/tasks/${TASK_ID}/artifact-preview" | tee PHASE720_FRESH_ARTIFACT_PREVIEW.json

echo ""

echo "[VERIFY] Semantic envelope marker:"

grep -n "MB_SEMANTIC_ARTIFACT_V1" PHASE720_FRESH_ARTIFACT_PREVIEW.json || true

echo ""

echo "[VERIFY] Markdown section preservation:"

grep -n "## Summary\\|## Deliverable\\|## Details\\|## Recommendations\\|## Next Steps\\|## Outcome" PHASE720_FRESH_ARTIFACT_PREVIEW.json || true

git add PHASE720_VALIDATE_FRESH_SEMANTIC_ENVELOPE.sh PHASE720_FRESH_TASK_RESPONSE.json PHASE720_FRESH_ARTIFACT_PREVIEW.json

git commit -m "Phase 720: validate fresh semantic envelope artifact"

git push origin phase719-artifact-visibility

git status --short

git log --oneline --decorate -5

