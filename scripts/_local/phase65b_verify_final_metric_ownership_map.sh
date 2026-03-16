#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Verify Final Metric Ownership Map"
echo

echo "1 Verifying metric-tasks owner..."
grep -F 'getElementById("metric-tasks")' public/js/telemetry/running_tasks_metric.js >/dev/null
if grep -F 'tasksNode.textContent = String(runningTaskIds.size);' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy metric-tasks writer still present"
  exit 1
fi
echo "OK"

echo
echo "2 Verifying metric-agents owner..."
grep -F 'const el = document.getElementById("metric-agents");' public/js/phase64_agent_activity_wire.js >/dev/null
grep -F 'el.textContent = String(getActiveAgentCount());' public/js/phase64_agent_activity_wire.js >/dev/null
if grep -F 'setMetricText(activeAgentsMetricEl, String(count));' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy metric-agents active writer still present"
  exit 1
fi
if grep -F 'setMetricText(activeAgentsMetricEl, "—");' public/js/agent-status-row.js >/dev/null; then
  echo "FAIL: legacy metric-agents reset/error writer still present"
  exit 1
fi
echo "OK"

echo
echo "3 Verifying metric-success owner..."
grep -F "const successNode = document.getElementById('metric-success');" public/js/agent-status-row.js >/dev/null
grep -F 'successNode.textContent = total > 0' public/js/agent-status-row.js >/dev/null
if grep -RIn 'metric-success' public/js/telemetry >/dev/null 2>&1; then
  echo "FAIL: telemetry writer detected for metric-success"
  exit 1
fi
echo "OK"

echo
echo "4 Verifying metric-latency owner..."
grep -F "const latencyNode = document.getElementById('metric-latency');" public/js/agent-status-row.js >/dev/null
grep -F "latencyNode.textContent = '—';" public/js/agent-status-row.js >/dev/null
grep -F 'latencyNode.textContent = formatLatency(avg);' public/js/agent-status-row.js >/dev/null
if grep -RIn 'metric-latency' public/js/telemetry >/dev/null 2>&1; then
  echo "FAIL: telemetry writer detected for metric-latency"
  exit 1
fi
echo "OK"

echo
echo "5 Running protection gate..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
echo

echo "FINAL OWNERSHIP MAP PASS"
