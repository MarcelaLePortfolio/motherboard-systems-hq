#!/usr/bin/env bash
set -euo pipefail

echo "== repo =="
pwd
git branch --show-current
git status --short

echo
echo "== success metric references across repo =="
rg -n 'metric-success|successNode|completedCount|failedCount|terminalSuccessTypes|terminalFailureTypes|recentDurationsMs' \
  public/js scripts public/dashboard.html .

echo
echo "== agent-status-row success ownership slice =="
python3 - << 'PY'
from pathlib import Path
p = Path("public/js/agent-status-row.js")
lines = p.read_text(encoding="utf-8").splitlines()
start = 360
end = 560
for n in range(start, end + 1):
    print(f"{n:04d}: {lines[n-1]}")
PY

echo
echo "== telemetry bootstrap files =="
find public/js/telemetry -maxdepth 2 -type f | sort

echo
echo "== running_tasks_metric.js template reference =="
sed -n '1,220p' public/js/telemetry/running_tasks_metric.js
