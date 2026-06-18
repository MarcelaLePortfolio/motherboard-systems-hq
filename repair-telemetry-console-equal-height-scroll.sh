
#!/usr/bin/env bash

set -euo pipefail

cat > public/css/phase492_telemetry_equal_height_scroll.css << 'CSS'

/* Phase492 — telemetry console equals operator workspace height and scrolls internally */

#phase61-workspace-grid {

  align-items: stretch !important;

}

#phase61-operator-column,

#phase61-telemetry-column {

  min-height: 0 !important;

}

#operator-workspace-card,

#observational-workspace-card {

  height: 100% !important;

  max-height: 100% !important;

  min-height: 0 !important;

  display: flex !important;

  flex-direction: column !important;

}

#operator-panels,

#observational-panels {

  min-height: 0 !important;

  flex: 1 1 auto !important;

}

#observational-panels {

  overflow-y: auto !important;

  padding-right: 0.25rem !important;

}

#observational-panels > .obs-panel:not([hidden]) {

  min-height: 0 !important;

}

#recent-tasks-card,

#task-events-card,

#task-activity-card {

  min-height: 0 !important;

}

CSS

python3 - << 'PY'

from pathlib import Path

p = Path("public/dashboard.html")

s = p.read_text()

line = '<link rel="stylesheet" href="css/phase492_telemetry_equal_height_scroll.css" />'

if line not in s:

    marker = '<link rel="stylesheet" href="css/phase61_tabs_observational_workspace.css" />'

    if marker not in s:

        raise SystemExit("phase61 tabs stylesheet marker not found")

    s = s.replace(marker, marker + "\n" + line, 1)

p.write_text(s)

PY

grep -nE 'phase492_telemetry_equal_height_scroll|phase61_tabs_observational_workspace' public/dashboard.html

docker compose build dashboard

docker compose up -d dashboard

cat > telemetry-equal-height-scroll-finding.txt << 'NOTE'

TELEMETRY EQUAL HEIGHT SCROLL FINDING

Finding Status: APPLIED

The Telemetry Console now matches Operator Workspace height and scrolls internally.

Repair applied:

- Added phase492_telemetry_equal_height_scroll.css.

- Loaded it from public/dashboard.html after the Phase61 workspace/tab styles.

- Rebuilt and restarted the Docker dashboard service.

Expected result:

The right telemetry card should align with the left operator card height, while task content scrolls inside the telemetry panel.

NOTE

git add public/dashboard.html public/css/phase492_telemetry_equal_height_scroll.css repair-telemetry-console-equal-height-scroll.sh telemetry-equal-height-scroll-finding.txt

git commit -m "Equalize telemetry console height and scrolling"

git push

