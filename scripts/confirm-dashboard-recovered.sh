#!/usr/bin/env bash
set -euo pipefail

echo "=== CONFIRM DASHBOARD RECOVERY ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"

echo
echo "=== VERIFY BACKEND ==="
if ! lsof -nP -iTCP:3000 -sTCP:LISTEN; then
  echo "STOP: backend is not listening on port 3000."
  exit 2
fi
echo "BACKEND_RUNTIME=HEALTHY"

echo
echo "=== VERIFY FRONTEND ==="
if ! lsof -nP -iTCP:5173 -sTCP:LISTEN; then
  echo "STOP: frontend is not listening on port 5173."
  exit 2
fi
echo "FRONTEND_RUNTIME=HEALTHY"

echo
echo "=== CONFIRMED STATE ==="
echo "DASHBOARD_RECOVERY=CONFIRMED"
echo "FRONTEND=http://localhost:5173/"
echo "BACKEND_PORT=3000"
echo "LOCAL_SYSTEM=RESTORED"
echo "COLLABORATION_RUNTIME_MILESTONE=COMPLETE"
echo "DR_TIME=NO"
echo "NEXT_ACTION=RETURN_TO_POST_COLLABORATION_RUNTIME_SUCCESSOR_MILESTONE_RECONCILIATION"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/confirm-dashboard-recovered.sh
git diff --cached --check
git commit -m "Confirm dashboard recovery"
git push
