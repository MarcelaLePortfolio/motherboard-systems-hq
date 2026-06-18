
#!/usr/bin/env bash

set -euo pipefail

node --check public/js/phase493_telemetry_height_sync.js

node --check public/js/dashboard-bundle-entry.js

grep -nE 'phase492_telemetry_equal_height_scroll|phase493_telemetry_height_sync|phase61_tabs_workspace|phase530_visible_panels_bridge' public/dashboard.html public/js/dashboard-bundle-entry.js public/css/phase492_telemetry_equal_height_scroll.css public/js/phase493_telemetry_height_sync.js || true

docker compose build dashboard

docker compose up -d dashboard

cat > telemetry-measured-height-sync-finding.txt << 'NOTE'

TELEMETRY MEASURED HEIGHT SYNC FINDING

Finding Status: APPLIED

Computed browser layout showed Operator Workspace at 640px and Telemetry Console at 1399px.

Repair applied:

- Added a measured browser-side height sync from operator-workspace-card to observational-workspace-card.

- Kept telemetry overflow constrained inside observational-panels/recent-tasks-card.

- Loaded phase493_telemetry_height_sync.js from dashboard-bundle-entry.js.

- Rebuilt and restarted the Docker dashboard service.

Expected result:

Telemetry Console should match Operator Workspace height and scroll internally.

NOTE

git add public/css/phase492_telemetry_equal_height_scroll.css public/js/phase493_telemetry_height_sync.js public/js/dashboard-bundle-entry.js repair-telemetry-measured-height-sync.sh telemetry-measured-height-sync-finding.txt

git commit -m "Add measured telemetry height sync"

git push

