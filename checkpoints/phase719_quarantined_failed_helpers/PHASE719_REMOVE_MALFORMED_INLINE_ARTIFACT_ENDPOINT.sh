
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REMOVE MALFORMED INLINE ARTIFACT ENDPOINT ====="

mkdir -p checkpoints

echo "[1] Save current broken route file excerpt"

{

  echo "BROKEN ROUTE FILE EXCERPT"

  nl -ba server/routes/api-tasks-postgres.mjs | sed -n '270,340p' || true

} > checkpoints/PHASE719_BROKEN_ARTIFACT_ENDPOINT_EXCERPT.txt

echo "[2] Remove malformed inline artifact endpoint block from task router"

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

markers = [

    "\n/**\n * GET /api/artifacts/:task_id",

    "\n/*\n * GET /api/artifacts/:task_id",

    "\n// GET /api/artifacts/:task_id",

]

cut = None

for marker in markers:

    idx = text.find(marker)

    if idx != -1:

        cut = idx

        break

if cut is None:

    raise SystemExit("No inline artifact endpoint marker found; refusing blind edit.")

new_text = text[:cut].rstrip() + "\n"

path.write_text(new_text)

PY

echo "[3] Verify syntax locally"

node --check server/routes/api-tasks-postgres.mjs

echo "[4] Save repaired route file excerpt"

{

  echo "REPAIRED ROUTE FILE TAIL"

  nl -ba server/routes/api-tasks-postgres.mjs | tail -n 80 || true

} > checkpoints/PHASE719_REPAIRED_TASK_ROUTER_TAIL.txt

echo "[5] Rebuild dashboard"

docker compose up -d --build dashboard

echo "[6] Wait for dashboard startup"

sleep 5

echo "[7] Verify runtime"

{

  echo "DASHBOARD LOGS"

  docker logs --tail 120 motherboard_systems_hq-dashboard-1 || true

  echo ""

  echo "ROOT ROUTE"

  curl -i -s --max-time 10 http://localhost:3000/ || true

  echo ""

  echo "TASK API HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "TASK API LIST"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks || true

  echo ""

  echo "ARTIFACT TEST ROUTE"

  curl -i -s --max-time 10 http://localhost:3000/api/artifacts/test || true

  echo ""

} | tee checkpoints/PHASE719_TASK_API_RECOVERY_VERIFY_AFTER_INLINE_ARTIFACT_REMOVAL.txt

echo "[8] Commit repair"

git add server/routes/api-tasks-postgres.mjs \

  PHASE719_REMOVE_MALFORMED_INLINE_ARTIFACT_ENDPOINT.sh \

  checkpoints/PHASE719_BROKEN_ARTIFACT_ENDPOINT_EXCERPT.txt \

  checkpoints/PHASE719_REPAIRED_TASK_ROUTER_TAIL.txt \

  checkpoints/PHASE719_TASK_API_RECOVERY_VERIFY_AFTER_INLINE_ARTIFACT_REMOVAL.txt

git commit -m "Phase 719: remove malformed inline artifact endpoint"

echo "[9] Push branch"

git push origin "$(git branch --show-current)"

echo "===== INLINE ARTIFACT ENDPOINT REMOVAL COMPLETE ====="

