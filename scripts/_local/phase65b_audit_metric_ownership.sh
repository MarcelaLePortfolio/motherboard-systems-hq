#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Audit Metric Ownership"
echo

echo "1 References to protected metric anchors:"
grep -RInE 'metric-agents|metric-tasks|metric-success|metric-latency' public/js || true
echo

echo "2 EventSource consumers touching task-events:"
grep -RInE 'EventSource|/events/task-events' public/js || true
echo

echo "3 Direct writes to metric text/value nodes:"
grep -RInE 'textContent\s*=|innerText\s*=|innerHTML\s*=' public/js | grep -E 'metric|tasks|success|latency|agents' || true
echo

echo "AUDIT COMPLETE"
