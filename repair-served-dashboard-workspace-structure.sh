
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

dashboard = Path("public/dashboard.html")

index = Path("public/index.html")

d = dashboard.read_text()

i = index.read_text()

start_marker = '<section id="phase61-workspace-shell"'

dashboard_end_marker = '<section id="phase61-atlas-band"'

index_end_marker = '<section id="atlas-status-card"'

d_start = d.find(start_marker)

d_end = d.find(dashboard_end_marker, d_start)

i_start = i.find(start_marker)

i_end = i.find(index_end_marker, i_start)

missing = []

if d_start < 0: missing.append("dashboard workspace start")

if d_end < 0: missing.append("dashboard atlas band end")

if i_start < 0: missing.append("index workspace start")

if i_end < 0: missing.append("index atlas status end")

if missing:

    raise SystemExit("Missing markers: " + ", ".join(missing))

replacement = i[i_start:i_end].rstrip() + "\n\n    "

d2 = d[:d_start] + replacement + d[d_end:]

dashboard.write_text(d2)

PY

echo "--- repaired workspace structure anchors ---"

grep -nE 'Telemetry Console|Execution Inspector|id="recentTasks"|id="tasks-widget"|id="phase61-atlas-band"|id="atlas-status-card"' public/dashboard.html || true

echo

echo "--- dashboard inline script syntax check ---"

./inspect-dashboard-inline-script-syntax.sh | tee dashboard-inline-script-syntax-after-structure-repair.txt

cat > served-dashboard-workspace-structure-repair-finding.txt << 'NOTE'

SERVED DASHBOARD WORKSPACE STRUCTURE REPAIR FINDING

Finding Status: APPLIED

The served dashboard retained older workspace body markup even after stylesheet and inline syntax repairs.

Repair applied:

- Replaced only the phase61 workspace shell in public/dashboard.html with the current workspace shell from public/index.html.

- Did not replace public/dashboard.html wholesale.

- Preserved the served dashboard route and surrounding dashboard file.

Next validation:

Hard-refresh /dashboard.html and confirm the visible structure matches the intended current operator/telemetry layout.

NOTE

git diff -- public/dashboard.html served-dashboard-workspace-structure-repair-finding.txt dashboard-inline-script-syntax-after-structure-repair.txt

git add public/dashboard.html served-dashboard-workspace-structure-repair-finding.txt dashboard-inline-script-syntax-after-structure-repair.txt repair-served-dashboard-workspace-structure.sh

git commit -m "Repair served dashboard workspace structure"

git push

