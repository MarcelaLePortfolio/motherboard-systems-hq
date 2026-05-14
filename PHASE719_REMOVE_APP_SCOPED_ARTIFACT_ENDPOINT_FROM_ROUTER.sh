
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: REMOVE APP-SCOPED ARTIFACT ENDPOINT FROM ROUTER ====="

mkdir -p checkpoints

echo "[1] Save pre-removal excerpt"

nl -ba server/routes/api-tasks-postgres.mjs | sed -n '285,380p' > checkpoints/PHASE719_APP_SCOPED_ARTIFACT_ENDPOINT_PREREMOVAL.txt || true

echo "[2] Remove malformed app.get artifact endpoint from router module"

python3 - << 'PY'

from pathlib import Path

import re

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

pattern = re.compile(

    r"\n\s*/\*\*\s*\n\s*\*\s*Phase 719\s*[—-]\s*Artifact Inspection Endpoint \(READ-ONLY\)\s*\n\s*\*\s*GET /api/artifacts/:task_id\s*\n\s*\*/\s*\n\s*app\.get\(\"/api/artifacts/:task_id\"[\s\S]*$"

)

new_text, count = pattern.subn("\n", text)

if count != 1:

    raise SystemExit(f"Expected to remove exactly 1 malformed app.get artifact endpoint block, removed {count}; refusing edit.")

path.write_text(new_text.rstrip() + "\n")

print("Removed malformed app.get artifact endpoint block from router module.")

PY

echo "[3] Verify syntax"

node --check server/routes/api-tasks-postgres.mjs

node --check server.js

echo "[4] Save post-removal tail"

nl -ba server/routes/api-tasks-postgres.mjs | tail -n 100 > checkpoints/PHASE719_APP_SCOPED_ARTIFACT_ENDPOINT_POSTREMOVAL.txt || true

echo "[5] Rebuild dashboard"

docker compose up -d --build dashboard

echo "[6] Wait for startup"

sleep 5

echo "[7] Verify runtime"

{

  echo "DASHBOARD CONTAINER"

  docker ps -a | grep motherboard_systems_hq-dashboard || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 160 motherboard_systems_hq-dashboard-1 || true

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

  echo "ARTIFACT TEST ROUTE EXPECTED TEMPORARILY ABSENT"

  curl -i -s --max-time 10 http://localhost:3000/api/artifacts/test || true

  echo ""

  echo "GIT STATUS"

  git status --short

} | tee checkpoints/PHASE719_RUNTIME_VERIFY_AFTER_APP_SCOPED_ENDPOINT_REMOVAL.txt

echo "[8] Commit recovery"

git add server/routes/api-tasks-postgres.mjs

git add PHASE719_REMOVE_APP_SCOPED_ARTIFACT_ENDPOINT_FROM_ROUTER.sh

git add PHASE719_FIX_ESCAPED_BACKTICKS_IN_ARTIFACT_ENDPOINT.sh || true

git add checkpoints/PHASE719_ESCAPED_BACKTICKS_PREFIX_EXCERPT.txt || true

git add checkpoints/PHASE719_ESCAPED_BACKTICKS_POSTFIX_EXCERPT.txt || true

git add checkpoints/PHASE719_RUNTIME_VERIFY_AFTER_ESCAPED_BACKTICK_FIX.txt || true

git add checkpoints/PHASE719_APP_SCOPED_ARTIFACT_ENDPOINT_PREREMOVAL.txt

git add checkpoints/PHASE719_APP_SCOPED_ARTIFACT_ENDPOINT_POSTREMOVAL.txt

git add checkpoints/PHASE719_RUNTIME_VERIFY_AFTER_APP_SCOPED_ENDPOINT_REMOVAL.txt

git commit -m "Phase 719: remove malformed app-scoped artifact endpoint from router"

echo "[9] Push branch"

git push origin "$(git branch --show-current)"

echo "===== ROUTER RECOVERY COMPLETE ====="

