
#!/usr/bin/env bash

set -euo pipefail

REPORT="PROMOTE_LATEST_DASHBOARD_TO_SERVED_ROOT.txt"

{

  echo "===== PROMOTE LATEST DASHBOARD TO SERVED ROOT ====="

  date

  echo

  echo "===== ROOT FILE DIAGNOSIS BEFORE ====="

  ls -lh public/index.html public/dashboard.html 2>/dev/null || true

  echo

  echo "===== TITLES BEFORE ====="

  grep -n "<title" public/index.html public/dashboard.html 2>/dev/null || true

  echo

  echo "===== PROMOTE DASHBOARD.HTML TO INDEX.HTML ====="

  cp public/dashboard.html public/index.html

  echo "Copied public/dashboard.html -> public/index.html"

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

  echo "===== ROOT CHECK ====="

  curl -i http://localhost:8080/ | head -80

  echo

  echo "===== DASHBOARD.HTML CHECK ====="

  curl -i http://localhost:8080/dashboard.html | head -80

  echo

  echo "===== HEALTH CHECK ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12'

  echo

  echo "===== FINAL FILE STATUS ====="

  ls -lh public/index.html public/dashboard.html public/bundle.js

  echo

  echo "===== WORKTREE ====="

  git status --short

} | tee "$REPORT"

git add promote-latest-dashboard-to-served-root.sh "$REPORT" public/index.html public/dashboard.html public/js public/bundle.js public/agent-status.json

git commit -m "Promote latest dashboard UI to served root"

git push

