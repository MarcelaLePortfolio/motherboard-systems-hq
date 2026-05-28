
#!/usr/bin/env bash

set -euo pipefail

REPORT="PHASE715_DASHBOARD_CANDIDATE_FINAL_VERIFY.txt"

{

  echo "===== PHASE715 DASHBOARD CANDIDATE FINAL VERIFY ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -8

  echo

  echo "===== COMPOSE PS ====="

  docker compose ps

  echo

  echo "===== ROOT HEADERS ====="

  curl -I http://localhost:8080/

  echo

  echo "===== ROOT SAMPLE ====="

  curl -sS http://localhost:8080/ | sed -n '1,120p'

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

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 120 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== WORKTREE ====="

  git status --short

  echo

  echo "Open: http://localhost:8080/?v=phase715-final"

} | tee "$REPORT"

git add restore-phase715-dashboard-candidate.sh verify-and-seal-phase715-dashboard-candidate.sh "$REPORT" public/index.html public/dashboard.html public/css public/js public/bundle.js public/agent-status.json backups/dashboard-ui-before-phase715-candidate

git commit -m "Verify and seal phase 715 dashboard candidate surface" || true

git push

