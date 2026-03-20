#!/usr/bin/env bash
set -euo pipefail

echo "== repo =="
pwd
git branch --show-current
git status --short

echo
echo "== agent-status-row metric node references =="
rg -n 'metric-tasks|metric-success|metric-latency|success|latency|tasksNode|successNode|latencyNode' public/js/agent-status-row.js || true

echo
echo "== agent-status-row metric ownership slice =="
python3 - << 'PY'
from pathlib import Path
p = Path("public/js/agent-status-row.js")
lines = p.read_text(encoding="utf-8").splitlines()
hits = []
for i, line in enumerate(lines, start=1):
    if any(token in line for token in [
        "metric-tasks", "metric-success", "metric-latency",
        "tasksNode", "successNode", "latencyNode",
        "Phase 65B.2: metric-tasks ownership transferred"
    ]):
        hits.append(i)

seen = set()
for i in hits:
    start = max(1, i - 20)
    end = min(len(lines), i + 35)
    if (start, end) in seen:
        continue
    seen.add((start, end))
    print(f"\n--- slice {start}:{end} ---")
    for n in range(start, end + 1):
        print(f"{n:04d}: {lines[n-1]}")
PY

echo
echo "== telemetry ownership guard files =="
find public/js/telemetry -maxdepth 2 -type f | sort
