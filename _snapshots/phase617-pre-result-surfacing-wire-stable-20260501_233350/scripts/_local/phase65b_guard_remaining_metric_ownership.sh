#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Guard Remaining Metric Ownership"
echo

echo "1 Verifying metric-success has exactly one direct writer..."
SUCCESS_WRITES="$(grep -RIn 'successNode\.textContent' public/js | wc -l | tr -d ' ')"
test "$SUCCESS_WRITES" = "1"
echo "OK"

echo
echo "2 Verifying metric-latency has exactly two direct writes in same owner..."
LATENCY_WRITES="$(grep -RIn 'latencyNode\.textContent' public/js | wc -l | tr -d ' ')"
test "$LATENCY_WRITES" = "2"
echo "OK"

echo
echo "3 Verifying both remaining metrics are still owned by agent-status-row.js..."
grep -F "const successNode = document.getElementById('metric-success');" public/js/agent-status-row.js >/dev/null
grep -F "const latencyNode = document.getElementById('metric-latency');" public/js/agent-status-row.js >/dev/null
echo "OK"

echo
echo "4 Verifying no telemetry writer exists yet for success/latency..."
if grep -RInE 'metric-success|metric-latency' public/js/telemetry >/dev/null 2>&1; then
  echo "FAIL: telemetry writer detected for success or latency"
  exit 1
fi
echo "OK"

echo
echo "OWNERSHIP GUARD PASS"
