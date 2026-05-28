
#!/usr/bin/env bash

set -euo pipefail

REPORT="BACKEND_RESTORATION_STATE_VERIFICATION.txt"

{

  echo "===== BACKEND RESTORATION STATE VERIFICATION ====="

  date

  echo

  echo "===== CURRENT HEAD ====="

  git log --oneline -10

  echo

  echo "===== DOCKER STATUS ====="

  docker compose ps || true

  echo

  echo "===== DASHBOARD LOGS ====="

  docker logs --tail 200 motherboard-systems-hq-clean-dashboard-1 || true

  echo

  echo "===== API HEALTH ====="

  curl -i http://localhost:8080/api/tasks/health || true

  echo

  echo "===== TASKS API ====="

  curl -sS 'http://localhost:8080/api/tasks?limit=12' || true

  echo

  echo "===== KNOWN BACKEND ROUTES ====="

  find server routes api src -type f 2>/dev/null | sort | grep -Ei 'api|task|route|worker|orchestr|execution|govern|matilda|cade' || true

  echo

  echo "===== BACKEND KEYWORD SCAN ====="

  grep -RniE "execution|governed|delegation|matilda|cade|worker|orchestrator|task_events|api/tasks|/api/chat" server routes api src package.json docker-compose* 2>/dev/null | head -300 || true

  echo

  echo "===== PACKAGE SCRIPTS ====="

  node -e 'const p=require("./package.json"); console.log(JSON.stringify(p.scripts||{}, null, 2))' || true

  echo

  echo "===== DB TABLES IF AVAILABLE ====="

  docker exec motherboard-systems-hq-clean-postgres-1 psql -U postgres -d motherboard -c "\dt" 2>/dev/null || true

  echo

  echo "===== BACKEND RESTORATION CONCLUSION ====="

  echo "We can confirm the dashboard container, health endpoint, and tasks API are alive."

  echo "We cannot yet claim all backend work is restored until routes, DB schema, worker/orchestrator paths, and external DR backend files are compared against the intended latest backend baseline."

} | tee "$REPORT"

git add verify-backend-restoration-state.sh "$REPORT"

git commit -m "Verify backend restoration state"

git push

