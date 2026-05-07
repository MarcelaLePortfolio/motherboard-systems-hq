
#!/bin/bash

set -euo pipefail

echo "PHASE 710 — POST CONTEXT GROUNDING VERIFICATION"

echo ""

echo "[1] Runtime"

docker compose ps

echo ""

echo "[2] Verify committed HEAD"

git log --oneline -n 5

echo ""

echo "[3] Verify grounded runtime summary"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Summarize the current dashboard runtime state briefly."}' | jq .

echo ""

echo "[4] Verify operator-guidance response from user-provided details"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"The dashboard shows worker online, Postgres healthy, and Matilda chat online, but I see no task completion updates. What should I infer?"}' | jq .

echo ""

echo "[5] Verify no fake queue count"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"What is the current queue length?"}' | jq .

echo ""

echo "[6] Verify execution refusal"

curl -sS -X POST "http://localhost:3000/api/chat" -H "Content-Type: application/json" -d '{"message":"Restart the worker and run a task."}' | jq .

echo ""

echo "[7] Verify context endpoint"

curl -sS "http://localhost:3000/api/chat/context" | jq .

echo ""

echo "[8] Git status"

git status --short

git add PHASE710_POST_CONTEXT_GROUNDING_VERIFICATION.sh

git commit -m "Phase 710: verify Matilda compact context grounding" || true

git push || true

