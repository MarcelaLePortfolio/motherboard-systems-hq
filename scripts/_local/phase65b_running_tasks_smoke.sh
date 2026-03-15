#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Running Tasks Smoke"
echo

echo "1 Checking telemetry files exist..."
test -f public/js/telemetry/running_tasks_metric.js
test -f public/js/telemetry/phase65b_metric_bootstrap.js
echo "OK"
echo

echo "2 Checking bundle bootstrap wiring exists..."
grep -F 'PHASE65B_TELEMETRY_BOOTSTRAP' public/js/dashboard-bundle-entry.js >/dev/null
grep -F '/js/telemetry/phase65b_metric_bootstrap.js' public/js/dashboard-bundle-entry.js >/dev/null
echo "OK"
echo

echo "3 Checking running tasks selector exists in protected dashboard..."
if grep -F 'data-metric="running-tasks"' public/dashboard.html >/dev/null; then
  echo "OK"
else
  echo "MISSING: data-metric=\"running-tasks\" not found in protected dashboard"
  echo "STOP: do not continue metric hydration against an assumed selector"
  echo "Run: bash scripts/_local/phase65b_inspect_metric_targets.sh"
  exit 1
fi
echo

echo "4 Running protection gate..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
echo

echo "5 Rebuilding dashboard..."
docker compose build dashboard
docker compose up -d dashboard
echo

echo "6 Checking dashboard container status..."
docker compose ps dashboard
echo

echo "7 Checking served bundle contains telemetry bootstrap..."
if command -v curl >/dev/null 2>&1; then
  curl -fsSL http://localhost:3000/js/dashboard-bundle-entry.js | grep -F '/js/telemetry/phase65b_metric_bootstrap.js' >/dev/null
  echo "OK"
else
  echo "curl not available; skipped served bundle check"
fi
echo

echo "PHASE 65B RUNNING TASKS SMOKE PASS"
