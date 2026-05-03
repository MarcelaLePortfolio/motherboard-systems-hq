#!/usr/bin/env bash
set -euo pipefail

echo "== repo =="
pwd
git branch --show-current
git status --short

echo
echo "== metric anchors in public/dashboard.html =="
rg -n 'metric-|Tasks Running|Success Rate|Latency|System metrics|tasks|success|latency' public/dashboard.html || true

echo
echo "== metrics row slice =="
python3 - << 'PY'
from pathlib import Path
p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")
lines = text.splitlines()
for i, line in enumerate(lines, start=1):
    if 'id="metrics-row"' in line:
        start = max(1, i - 20)
        end = min(len(lines), i + 120)
        for n in range(start, end + 1):
            print(f"{n:04d}: {lines[n-1]}")
        break
PY

echo
echo "== telemetry directory =="
find public/js/telemetry -maxdepth 2 -type f | sort

echo
echo "== running_tasks_metric.js =="
sed -n '1,260p' public/js/telemetry/running_tasks_metric.js

echo
echo "== phase65b_metric_bootstrap.js =="
sed -n '1,260p' public/js/telemetry/phase65b_metric_bootstrap.js

echo
echo "== bundle entry =="
sed -n '1,220p' public/js/dashboard-bundle-entry.js

echo
echo "== task-events consumers touching metrics =="
grep -RInE '/events/task-events|EventSource|metric-tasks|metric-success|metric-latency|telemetry' public/js | sort || true
