#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Audit Metric-Agents Ownership"
echo

echo "1 metric-agents references"
grep -RIn 'metric-agents' public/js public/dashboard.html || true
echo

echo "2 direct writes affecting metric-agents"
grep -RInE 'metric-agents|activeAgentsMetricEl|textContent\s*=|innerText\s*=|innerHTML\s*=' public/js | grep -E 'metric-agents|activeAgentsMetricEl' || true
echo

echo "3 likely owners touching agent activity"
grep -RInE 'metric-agents|agent-status|agent activity|task-events|EventSource|OPS_SSE_URL|/events/task-events|/events/ops' public/js | grep -E 'agent-status-row|phase64_agent_activity_wire|telemetry|dashboard-status|ops-globals-bridge' || true
echo

echo "4 count of direct metric-agents node lookups"
COUNT="$(grep -RIn 'getElementById("metric-agents")\|getElementById('\''metric-agents'\'')' public/js | wc -l | tr -d ' ')"
echo "metric-agents lookup count: $COUNT"
echo

echo "AUDIT COMPLETE"
