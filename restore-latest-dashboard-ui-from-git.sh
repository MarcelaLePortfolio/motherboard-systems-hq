
#!/usr/bin/env bash

set -euo pipefail

REPORT="LATEST_DASHBOARD_UI_RESTORE_FROM_GIT.txt"

TARGET_COMMIT="4c55719f"

{

  echo "===== RESTORE LATEST DASHBOARD UI FROM GIT ====="

  date

  echo

  echo "===== TARGET UI COMMIT ====="

  git show --no-patch --oneline "$TARGET_COMMIT"

  echo

  echo "===== RESTORE DASHBOARD UI FILES ====="

  git checkout "$TARGET_COMMIT" -- public/dashboard.html public/css public/js

  echo "Restored public/dashboard.html, public/css, and public/js from $TARGET_COMMIT"

  echo

  echo "===== REBUILD DASHBOARD BUNDLE ====="

  npx esbuild public/js/dashboard-bundle-entry.js --bundle --format=esm --outfile=public/bundle.js

  echo

  echo "===== REBUILD DASHBOARD IMAGE ====="

  docker compose build dashboard

  echo

  echo "===== RESTART DASHBOARD ====="

  docker compose up -d dashboard

  sleep 8

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== DASHBOARD ROOT ====="

  curl -I http://localhost:8080/

  echo

  echo "===== HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== AGENT STATUS JSON ====="

  curl -i http://localhost:8080/agent-status.json || true

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12'

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$REPORT"

git add restore-latest-dashboard-ui-from-git.sh "$REPORT" public/dashboard.html public/css public/js public/bundle.js public/agent-status.json

git commit -m "Restore latest dashboard UI surface from git history"

git push

