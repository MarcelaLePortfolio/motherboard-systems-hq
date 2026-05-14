
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: FIX ESCAPED BACKTICKS IN ARTIFACT ENDPOINT ====="

mkdir -p checkpoints

echo "[1] Save pre-fix excerpt"

nl -ba server/routes/api-tasks-postgres.mjs | sed -n '289,335p' > checkpoints/PHASE719_ESCAPED_BACKTICKS_PREFIX_EXCERPT.txt

echo "[2] Replace escaped backticks with real template literal backticks"

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

count = text.count("\\`")

if count < 2:

    raise SystemExit(f"Expected at least 2 escaped backticks, found {count}; refusing edit.")

text = text.replace("\\`", "`")

path.write_text(text)

print(f"Replaced {count} escaped backtick tokens.")

PY

echo "[3] Verify syntax"

node --check server/routes/api-tasks-postgres.mjs

node --check server.js

echo "[4] Save post-fix excerpt"

nl -ba server/routes/api-tasks-postgres.mjs | sed -n '289,335p' > checkpoints/PHASE719_ESCAPED_BACKTICKS_POSTFIX_EXCERPT.txt

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

  docker logs --tail 140 motherboard_systems_hq-dashboard-1 || true

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

} | tee checkpoints/PHASE719_RUNTIME_VERIFY_AFTER_ESCAPED_BACKTICK_FIX.txt

echo "[8] Commit fix"

git add server/routes/api-tasks-postgres.mjs \

  PHASE719_FIX_ESCAPED_BACKTICKS_IN_ARTIFACT_ENDPOINT.sh \

  checkpoints/PHASE719_ESCAPED_BACKTICKS_PREFIX_EXCERPT.txt \

  checkpoints/PHASE719_ESCAPED_BACKTICKS_POSTFIX_EXCERPT.txt \

  checkpoints/PHASE719_RUNTIME_VERIFY_AFTER_ESCAPED_BACKTICK_FIX.txt

git commit -m "Phase 719: fix escaped backticks in artifact endpoint"

echo "[9] Push branch"

git push origin "$(git branch --show-current)"

echo "===== ESCAPED BACKTICK FIX COMPLETE ====="

