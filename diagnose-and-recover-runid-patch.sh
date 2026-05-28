
#!/usr/bin/env bash

set -euo pipefail

REPORT="RUNID_PATCH_CRASH_DIAGNOSIS.txt"

{

  echo "===== RUN_ID PATCH CRASH DIAGNOSIS ====="

  date

  echo

  echo "===== GIT STATUS ====="

  git status --short

  echo

  echo "===== CURRENT DIFF ====="

  git diff -- server/tasks-mutations.mjs || true

  echo

  echo "===== DOCKER STATE ====="

  docker compose ps || true

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 180 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== HEALTH CHECK ====="

  curl -i http://localhost:8080/api/tasks/health || true

} | tee "$REPORT"

if ! curl -fsS http://localhost:8080/api/tasks/health >/dev/null 2>&1; then

  echo "===== HEALTH FAILED: REVERTING UNCOMMITTED RUN_ID PATCH =====" | tee -a "$REPORT"

  git checkout -- server/tasks-mutations.mjs

  docker compose build dashboard

  docker compose up -d dashboard

  curl -i http://localhost:8080/api/tasks/health || true

fi

git add "$REPORT" diagnose-and-recover-runid-patch.sh

git commit -m "Diagnose run id patch crash" || true

git push

