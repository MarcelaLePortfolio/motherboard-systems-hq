#!/usr/bin/env bash
set -euo pipefail

echo "== repo =="
pwd
git branch --show-current
git status --short

echo
echo "== metric-agents references across repo =="
rg -n 'metric-agents|Active Agents|agent activity|agent-status-container|phase64_agent_activity_wire|agent-status-row' \
  public/js scripts public/dashboard.html .

echo
echo "== metric-agents live writer slices =="
python3 - << 'PY'
from pathlib import Path

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/js/phase64_agent_activity_wire.js"),
]

for path in targets:
    if not path.exists():
        continue
    print(f"\n===== {path} =====")
    lines = path.read_text(encoding="utf-8").splitlines()
    hits = []
    for i, line in enumerate(lines, start=1):
        if any(token in line for token in [
            "metric-agents",
            "Active Agents",
            "agent activity",
            "textContent",
            "getElementById('metric-agents')",
            'getElementById("metric-agents")',
        ]):
            hits.append(i)
    shown = set()
    for i in hits[:12]:
        start = max(1, i - 20)
        end = min(len(lines), i + 35)
        key = (start, end)
        if key in shown:
            continue
        shown.add(key)
        print(f"\n--- slice {start}:{end} ---")
        for n in range(start, end + 1):
            print(f"{n:04d}: {lines[n-1]}")
PY

echo
echo "== current telemetry-owned files =="
find public/js/telemetry -maxdepth 2 -type f | sort

echo
echo "== current protected metric anchors =="
python3 - << 'PY'
from pathlib import Path
import re

text = Path("public/dashboard.html").read_text(encoding="utf-8")
for m in re.finditer(r'id="(metric-[^"]+)"', text):
    print(m.group(1))
PY
