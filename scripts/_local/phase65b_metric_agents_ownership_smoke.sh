#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B.6 — Metric-Agents Ownership Smoke"
echo

echo "1 Verifying phase64_agent_activity_wire.js still owns metric-agents..."
grep -F 'const el = document.getElementById("metric-agents");' public/js/phase64_agent_activity_wire.js >/dev/null
grep -F 'el.textContent = String(getActiveAgentCount());' public/js/phase64_agent_activity_wire.js >/dev/null
echo "OK"
echo

echo "2 Verifying legacy agent-status-row.js direct writers removed..."
if grep -F 'setMetricText(activeAgentsMetricEl, String(count));' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy active metric-agents writer still present"
  exit 1
fi
if grep -F 'setMetricText(activeAgentsMetricEl, "—");' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy reset/error metric-agents writer still present"
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

echo "PHASE 65B.6 METRIC-AGENTS OWNERSHIP SMOKE PASS"
