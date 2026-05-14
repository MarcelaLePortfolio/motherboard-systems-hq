
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 BACKEND DIFF + RUNTIME INSPECTION ====="

echo ""

echo "[1] Current branch and status"

git branch --show-current

git status --short

echo ""

echo "[2] Full backend diff summary"

git diff --stat -- server.js server/routes/api-tasks-postgres.mjs

echo ""

echo "[3] Save full backend diff to checkpoint file"

mkdir -p checkpoints

git diff -- server.js server/routes/api-tasks-postgres.mjs > checkpoints/PHASE719_BACKEND_DIFF_BEFORE_UI.patch

echo ""

echo "[4] Verify dashboard health"

curl -i -s http://localhost:3000/ | head -n 30 || true

echo ""

echo "[5] Verify task API health"

curl -s http://localhost:3000/api/tasks | head -c 1000 || true

echo ""

echo ""

echo "[6] Verify artifact endpoint shape with placeholder task id"

curl -i -s http://localhost:3000/api/artifacts/test | head -n 60 || true

echo ""

echo "[7] Locate frontend task renderer candidates"

find . \( -path "./node_modules" -o -path "./.git" -o -path "./_snapshots" \) -prune -o \

  \( -name "*.js" -o -name "*.mjs" -o -name "*.ts" -o -name "*.tsx" -o -name "*.html" \) -print | \

  xargs grep -nE "Recent Tasks|Task History|task-card|taskCard|tasks-container|/api/tasks|renderTasks|task_id|task.id|dataset.task" 2>/dev/null | head -n 250 \

  | tee checkpoints/PHASE719_FRONTEND_TASK_RENDERER_CANDIDATES.txt

echo ""

echo "[8] Checkpoint inspection artifacts only"

git add checkpoints/PHASE719_BACKEND_DIFF_BEFORE_UI.patch checkpoints/PHASE719_FRONTEND_TASK_RENDERER_CANDIDATES.txt PHASE719_BACKEND_DIFF_AND_RUNTIME_INSPECT.sh

git commit -m "Phase 719: inspect backend diff before artifact UI work"

git push origin phase719-artifact-visibility-ui

echo ""

echo "===== INSPECTION COMPLETE ====="

