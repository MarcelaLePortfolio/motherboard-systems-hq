#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Audit Remaining Metric Writers"
echo

echo "1 metric-success references"
grep -RIn 'metric-success' public/js public/dashboard.html || true
echo

echo "2 metric-latency references"
grep -RIn 'metric-latency' public/js public/dashboard.html || true
echo

echo "3 direct writes affecting success/latency"
grep -RInE 'successNode\.textContent|latencyNode\.textContent|metric-success|metric-latency' public/js || true
echo

echo "4 task-events consumers that may influence remaining metrics"
grep -RInE '/events/task-events|EventSource' public/js | grep -E 'agent-status-row|phase64_agent_activity_wire|task-events-sse-client|telemetry' || true
echo

echo "AUDIT COMPLETE"
