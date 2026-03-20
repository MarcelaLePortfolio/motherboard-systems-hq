#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Inspect Metric-Agents Context"
echo

echo "1 agent-status-row.js around metric-agents references"
grep -n 'metric-agents\|activeAgentsMetricEl\|setMetricText(activeAgentsMetricEl' public/js/agent-status-row.js || true
echo
python3 - << 'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
lines = path.read_text().splitlines()
targets = ["metric-agents", "activeAgentsMetricEl", "setMetricText(activeAgentsMetricEl"]
shown = set()

for idx, line in enumerate(lines, start=1):
    if any(t in line for t in targets):
        start = max(1, idx - 6)
        end = min(len(lines), idx + 6)
        key = (start, end)
        if key in shown:
            continue
        shown.add(key)
        print(f"--- public/js/agent-status-row.js:{start}-{end} ---")
        for n in range(start, end + 1):
            print(f"{n}: {lines[n-1]}")
        print()
PY

echo "2 phase64_agent_activity_wire.js around metric-agents references"
grep -n 'metric-agents\|getElementById("metric-agents")\|getElementById('\''metric-agents'\'')' public/js/phase64_agent_activity_wire.js || true
echo
python3 - << 'PY'
from pathlib import Path

path = Path("public/js/phase64_agent_activity_wire.js")
lines = path.read_text().splitlines()
targets = ["metric-agents", 'getElementById("metric-agents")', "getElementById('metric-agents')"]
shown = set()

for idx, line in enumerate(lines, start=1):
    if any(t in line for t in targets):
        start = max(1, idx - 10)
        end = min(len(lines), idx + 20)
        key = (start, end)
        if key in shown:
            continue
        shown.add(key)
        print(f"--- public/js/phase64_agent_activity_wire.js:{start}-{end} ---")
        for n in range(start, end + 1):
            print(f"{n}: {lines[n-1]}")
        print()
PY

echo "3 explicit writes near metric-agents in phase64_agent_activity_wire.js"
grep -nE 'textContent|innerText|innerHTML|setAttribute|classList' public/js/phase64_agent_activity_wire.js || true
echo

echo "INSPECTION COMPLETE"
