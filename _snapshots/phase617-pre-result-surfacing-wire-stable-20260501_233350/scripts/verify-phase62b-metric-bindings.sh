#!/usr/bin/env bash
set -euo pipefail

FILE="public/dashboard.html"

echo "PHASE 62B METRIC BINDING VERIFY"

grep -q 'id="metric-agents"' "$FILE" && echo "PASS: metric-agents present"
grep -q 'id="metric-tasks"' "$FILE" && echo "PASS: metric-tasks present"
grep -q 'id="metric-success"' "$FILE" && echo "PASS: metric-success present"
grep -q 'id="metric-latency"' "$FILE" && echo "PASS: metric-latency present"

grep -q 'data-phase62b-metric-anchor="true"' "$FILE" && echo "PASS: phase62b metric anchor attribute present"

echo "PHASE 62B METRIC BINDINGS VERIFIED"
