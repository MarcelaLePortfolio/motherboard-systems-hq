#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Guard Metric-Agents Ownership"
echo

echo "1 Verifying metric-agents anchor exists in protected dashboard..."
grep -F 'id="metric-agents"' public/dashboard.html >/dev/null
echo "OK"

echo
echo "2 Verifying sole active writer lives in phase64_agent_activity_wire.js..."
grep -F 'const el = document.getElementById("metric-agents");' public/js/phase64_agent_activity_wire.js >/dev/null
grep -F 'el.textContent = String(getActiveAgentCount());' public/js/phase64_agent_activity_wire.js >/dev/null
echo "OK"

echo
echo "3 Verifying legacy activeAgentsMetricEl writers are removed from agent-status-row.js..."
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
echo "4 Verifying total metric-agents direct write count is exactly one..."
COUNT="$(grep -RIn 'textContent = String(getActiveAgentCount())' public/js | wc -l | tr -d ' ')"
test "$COUNT" = "1"
echo "OK"

echo
echo "5 Running protection gate..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
echo

echo "OWNERSHIP GUARD PASS"
