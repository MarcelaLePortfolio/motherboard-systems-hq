
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: FIX ARTIFACT PREVIEW POOL REFERENCE ====="

mkdir -p checkpoints

BRANCH="$(git branch --show-current)"

TARGET="server/routes/api-tasks-postgres.mjs"

cp "$TARGET" checkpoints/PHASE719_API_TASKS_POSTGRES_PRE_POOL_REFERENCE_FIX.mjs

python3 - << 'PY'

from pathlib import Path

path = Path("server/routes/api-tasks-postgres.mjs")

text = path.read_text()

if "globalThis.__DB_POOL.query" in text:

    raise SystemExit("Pool reference already patched.")

if "const q = await pool.query(" not in text:

    raise SystemExit("Expected pool.query line not found; refusing patch.")

text = text.replace(

    "const q = await pool.query(",

    "const q = await globalThis.__DB_POOL.query(",

    1

)

path.write_text(text)

PY

node --check "$TARGET"

cp "$TARGET" checkpoints/PHASE719_API_TASKS_POSTGRES_POST_POOL_REFERENCE_FIX.mjs

docker compose up -d --build dashboard

sleep 5

TASK_ID="t_d1efc418-5049-401c-89fe-19eaceb8f784"

{

  echo "RUNTIME HEALTH"

  curl -i -s --max-time 10 http://localhost:3000/api/tasks/health || true

  echo ""

  echo "ARTIFACT PREVIEW ROUTE"

  curl -i -s --max-time 10 "http://localhost:3000/api/tasks/$TASK_ID/artifact-preview" | head -n 160 || true

  echo ""

  echo "ROUTE MARKERS"

  grep -nE "artifact-preview|globalThis.__DB_POOL|artifact_path_rejected|artifact_preview_failed" "$TARGET" || true

  echo ""

  echo "DASHBOARD LOGS"

  docker logs --tail 140 motherboard_systems_hq-dashboard-1 || true

} | tee checkpoints/PHASE719_POOL_REFERENCE_FIX_VERIFY.txt

git add "$TARGET"

git add PHASE719_FIX_ARTIFACT_PREVIEW_POOL_REFERENCE.sh

git add checkpoints/PHASE719_API_TASKS_POSTGRES_PRE_POOL_REFERENCE_FIX.mjs

git add checkpoints/PHASE719_API_TASKS_POSTGRES_POST_POOL_REFERENCE_FIX.mjs

git add checkpoints/PHASE719_POOL_REFERENCE_FIX_VERIFY.txt

git commit -m "Phase 719: fix artifact preview pool reference"

git push origin "$BRANCH"

echo "===== ARTIFACT PREVIEW POOL REFERENCE FIX COMPLETE ====="

