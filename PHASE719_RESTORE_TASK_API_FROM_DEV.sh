
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719: RESTORE TASK API FROM DEV ====="

mkdir -p checkpoints

echo "[1] Confirm branch"

git branch --show-current

echo "[2] Restore only task API/dashboard route wiring files from dev"

git checkout dev -- server.js server/routes/api-tasks-postgres.mjs

echo "[3] Save recovery note"

cat > checkpoints/PHASE719_TASK_API_RESTORED_FROM_DEV.md << 'NOTE'

PHASE 719 TASK API RESTORED FROM DEV

Reason:

- Current branch runtime showed root placeholder only.

- Current branch runtime showed /api/tasks returning Cannot GET /api/tasks.

- Baseline comparison confirmed dev contains restored task API routing:

  app.use("/api/tasks", apiTasksRouter)

  express.static dashboard/public serving

  apiTasksRouter export shape

Action:

- Restored only:

  server.js

  server/routes/api-tasks-postgres.mjs

Source:

- dev

Next:

- Restart dashboard.

- Verify /api/tasks.

- Verify dashboard route.

- Then resume artifact UI work only after stable runtime confirmation.

NOTE

echo "[4] Commit restoration"

git add server.js server/routes/api-tasks-postgres.mjs checkpoints/PHASE719_TASK_API_RESTORED_FROM_DEV.md PHASE719_RESTORE_TASK_API_FROM_DEV.sh

git commit -m "Phase 719: restore task API baseline from dev"

echo "[5] Push branch"

git push origin phase719-artifact-visibility-ui

echo "[6] Restart dashboard"

docker compose restart dashboard

echo "[7] Verify root route"

curl -i -s http://localhost:3000/ | head -n 40 || true

echo "[8] Verify task API"

curl -i -s http://localhost:3000/api/tasks | head -n 80 || true

echo "[9] Verify artifact test route"

curl -i -s http://localhost:3000/api/artifacts/test | head -n 80 || true

echo "===== TASK API RESTORE COMPLETE ====="

