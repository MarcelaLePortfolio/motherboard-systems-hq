
#!/bin/bash

set -euo pipefail

docker compose up -d --build dashboard

echo "[1] Containers"

docker compose ps

echo ""

echo "[2] Valid retry payload"

curl -sS -X POST http://localhost:3000/api/delegate-task -H "Content-Type: application/json" -d '{"kind":"retry","title":"Phase 717 retry contract validation","agent":"Matilda","notes":"valid retry contract probe","strategy":"fresh-context","meta":{"retry_of_task_id":"phase717-probe"}}' | python3 -m json.tool

echo ""

echo "[3] Invalid retry payload should reject"

curl -sS -i -X POST http://localhost:3000/api/delegate-task -H "Content-Type: application/json" -d '{"kind":"retry","title":"Phase 717 invalid retry probe"}' | sed -n '1,30p'

echo ""

echo "[4] Git state"

git status --short

git log --oneline --decorate -5

