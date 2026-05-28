
#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE715_DASHBOARD_CANDIDATE_RESTORE.txt"

TARGET="phase715-pre-execution-evidence-ui"

{

  echo "===== PHASE 715 DASHBOARD CANDIDATE RESTORE ====="

  date

  echo

  echo "===== CURRENT HEAD BEFORE ====="

  git log --oneline -8

  echo

  echo "===== VERIFY TARGET ====="

  git rev-parse --verify "$TARGET"

  echo

  echo "===== BACKUP CURRENT PHASE91 SERVED SURFACE ====="

  mkdir -p backups/dashboard-ui-before-phase715-candidate

  cp public/index.html backups/dashboard-ui-before-phase715-candidate/index.html

  cp public/dashboard.html backups/dashboard-ui-before-phase715-candidate/dashboard.html

  cp public/bundle.js backups/dashboard-ui-before-phase715-candidate/bundle.js

  echo "backup complete"

  echo

  echo "===== RESTORE PHASE715 PUBLIC UI SURFACES ====="

  git checkout "$TARGET" -- public/index.html public/dashboard.html public/css public/js public/bundle.js

  echo "restored public/index.html, public/dashboard.html, public/css, public/js, public/bundle.js from $TARGET"

  echo

  echo "===== PRESERVE AGENT STATUS JSON ====="

  if [ ! -f public/agent-status.json ]; then

    cat > public/agent-status.json << 'JSON'

{

  "agents": {

    "matilda": { "status": "restored", "mode": "dashboard-ui-runtime" },

    "atlas": { "status": "restored", "mode": "dashboard-ui-runtime" },

    "cade": { "status": "restored", "mode": "dashboard-ui-runtime" },

    "effie": { "status": "restored", "mode": "dashboard-ui-runtime" }

  }

}

JSON

  fi

  echo

  echo "===== REBUILD DASHBOARD IMAGE ====="

  docker compose build dashboard

  echo

  echo "===== RESTART DASHBOARD ====="

  docker compose up -d dashboard

  sleep 8

  echo

  echo "===== VERIFY RUNTIME ====="

  docker compose ps

  echo

  echo "===== ROOT CHECK ====="

  curl -i http://localhost:8080/ | head -100

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

  echo "===== MARKER CHECK ====="

  grep -ni "execution inspector\|task history\|recent tasks\|artifact preview\|matilda\|operator guidance\|phase715\|phase719\|phase530" public/index.html | head -120 || true

  echo

  echo "===== FILE SIZE CHECK ====="

  wc -c public/index.html public/dashboard.html public/bundle.js

  echo

  echo "===== WORKTREE ====="

  git status --short

  echo

  echo "Open: http://localhost:8080/?v=phase715-candidate"

} | tee "$REPORT"

git add restore-phase715-dashboard-candidate.sh "$REPORT" public/index.html public/dashboard.html public/css public/js public/bundle.js public/agent-status.json backups/dashboard-ui-before-phase715-candidate

git commit -m "Restore phase 715 dashboard candidate surface"

git push

