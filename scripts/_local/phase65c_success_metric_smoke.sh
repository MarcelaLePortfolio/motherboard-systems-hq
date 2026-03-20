#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65C — Success Rate Smoke"

echo "1 Checking telemetry files exist..."
test -f public/js/telemetry/running_tasks_metric.js
test -f public/js/telemetry/success_rate_metric.js
test -f public/js/telemetry/phase65b_metric_bootstrap.js

echo "2 Checking bootstrap loads success metric..."
grep -F '/js/telemetry/success_rate_metric.js' public/js/telemetry/phase65b_metric_bootstrap.js >/dev/null

echo "3 Checking agent-status-row no longer writes metric-success..."
if grep -F 'successNode.textContent = total > 0' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy metric-success writer still present"
  exit 1
fi
grep -F 'metric-success ownership transferred to telemetry reducer' public/js/agent-status-row.js >/dev/null

echo "4 Checking protected success anchor exists..."
grep -F 'id="metric-success"' public/dashboard.html >/dev/null

echo "5 Running protection gates..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
bash scripts/verify-dashboard-layout-contract.sh public/dashboard.html
bash scripts/verify-phase62-dashboard-golden.sh

echo "6 Rebuilding dashboard..."
docker compose build dashboard
docker compose up -d dashboard

echo "7 Checking dashboard container status..."
docker compose ps dashboard

echo "8 Waiting for dashboard HTTP readiness on :8080..."
for i in {1..60}; do
  code="$(curl -sS -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/dashboard || true)"
  if [ "$code" = "200" ]; then
    echo "dashboard ready"
    break
  fi
  sleep 2
done
[ "${code:-}" = "200" ]

echo "9 Checking served bootstrap contains success metric..."
curl -fsSL http://127.0.0.1:8080/js/telemetry/phase65b_metric_bootstrap.js | grep -F '/js/telemetry/success_rate_metric.js' >/dev/null

echo "10 Checking dashboard HTML still exposes protected metrics..."
curl -fsSL http://127.0.0.1:8080/dashboard | grep -E 'metric-tasks|metric-success|metric-latency' >/dev/null

echo "SUCCESS: Phase 65C success metric ownership transfer smoke passed."
