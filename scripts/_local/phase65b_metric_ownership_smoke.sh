#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B.2 — Metric Ownership Smoke"
echo

echo "1 Verifying telemetry owns metric-tasks..."
grep -F 'getElementById("metric-tasks")' public/js/telemetry/running_tasks_metric.js >/dev/null
echo "OK"
echo

echo "2 Verifying legacy direct writer removed..."
if grep -F 'tasksNode.textContent = String(runningTaskIds.size);' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy metric-tasks writer still present"
  exit 1
fi
echo "OK"
echo

echo "3 Running protection gate..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
echo

echo "4 Rebuilding dashboard..."
docker compose build dashboard
docker compose up -d dashboard
echo

echo "5 Checking dashboard HTTP readiness on :8080..."
for _ in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsSL http://localhost:8080/ >/dev/null 2>&1; then
    echo "OK"
    break
  fi
  sleep 1
done
curl -fsSL http://localhost:8080/ >/dev/null
echo

echo "6 Checking served bundle still includes telemetry bootstrap..."
curl -fsSL http://localhost:8080/js/dashboard-bundle-entry.js | grep -F '/js/telemetry/phase65b_metric_bootstrap.js' >/dev/null
echo "OK"
echo

echo "PHASE 65B.2 METRIC OWNERSHIP SMOKE PASS"
