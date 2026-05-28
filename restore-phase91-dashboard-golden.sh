
#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE91_DASHBOARD_GOLDEN_RESTORE.txt"

TARGET="v91.0-guidance-intelligence-refinement-golden"

{

  echo "===== PHASE 91 DASHBOARD GOLDEN RESTORE ====="

  date

  echo

  echo "===== CURRENT HEAD BEFORE ====="

  git log --oneline -8

  echo

  echo "===== VERIFY TARGET TAG ====="

  git rev-parse --verify "$TARGET"

  echo

  echo "===== BACKUP CURRENT SERVED DASHBOARD FILES ====="

  mkdir -p backups/dashboard-ui-before-phase91-restore

  cp -f public/index.html backups/dashboard-ui-before-phase91-restore/index.html 2>/dev/null || true

  cp -f public/dashboard.html backups/dashboard-ui-before-phase91-restore/dashboard.html 2>/dev/null || true

  cp -f public/bundle.js backups/dashboard-ui-before-phase91-restore/bundle.js 2>/dev/null || true

  echo "backup complete"

  echo

  echo "===== RESTORE PHASE 91 PUBLIC DASHBOARD SURFACES ====="

  git checkout "$TARGET" -- public/dashboard.html public/css public/js || true

  cp -f public/dashboard.html public/index.html

  echo "restored public/dashboard.html, public/css, public/js, and promoted dashboard.html to index.html"

  echo

  echo "===== REBUILD DASHBOARD BUNDLE ====="

  if npm run build:dashboard; then

    echo "build:dashboard succeeded"

  elif npm run build; then

    echo "build succeeded"

  else

    npx esbuild public/js/dashboard-bundle-entry.js --bundle --format=esm --outfile=public/bundle.js

  fi

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

  curl -i http://localhost:8080/ | head -120

  echo

  echo "===== DASHBOARD MARKER CHECK ====="

  curl -s http://localhost:8080/ > /tmp/phase91-root.html

  wc -c /tmp/phase91-root.html

  grep -ni "phase-91\|phase 91\|guidance intelligence\|operator guidance\|matilda\|phase62-top-row\|phase61-telemetry-column" /tmp/phase91-root.html | head -120 || true

  echo

  echo "===== HEALTH CHECK ====="

  curl -i http://localhost:8080/api/tasks/health

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12'

  echo

  echo "===== AGENT STATUS JSON ====="

  curl -i http://localhost:8080/agent-status.json || true

  echo

  echo "===== WORKTREE ====="

  git status --short

  echo

  echo "===== FINDING ====="

  echo "Phase 91 golden dashboard public surfaces restored to served root."

  echo "If browser still appears stale, open http://localhost:8080/?v=phase91-golden"

} | tee "$REPORT"

git add restore-phase91-dashboard-golden.sh "$REPORT" public/index.html public/dashboard.html public/css public/js public/bundle.js public/agent-status.json backups/dashboard-ui-before-phase91-restore || true

git commit -m "Restore phase 91 golden dashboard UI surface"

git push

