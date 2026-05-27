PHASE 65 — CANONICAL RESTORE PROCEDURE
Date: 2026-03-14

Purpose:
Define a single deterministic restore path for dashboard structural recovery.

Golden Restore Anchor:

v63.0-telemetry-integration-golden

Protected Recovery Files:

public/dashboard.html
public/css/dashboard.css
public/js/phase61_tabs_workspace.js
public/js/phase61_recent_history_wire.js

Canonical Restore Procedure:

git checkout v63.0-telemetry-integration-golden -- public/dashboard.html

git checkout v63.0-telemetry-integration-golden -- public/css/dashboard.css

git checkout v63.0-telemetry-integration-golden -- public/js/phase61_tabs_workspace.js

git checkout v63.0-telemetry-integration-golden -- public/js/phase61_recent_history_wire.js

docker compose build dashboard

docker compose up -d dashboard

Verification Steps:

Dashboard loads
Tabs function
Telemetry renders
Atlas full width
Operator + Telemetry side-by-side

Rules:

Never repair broken layout.
Always restore from golden.
Only modify after restore verified.

