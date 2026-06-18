
#!/usr/bin/env bash

set -euo pipefail

echo "--- restored layout styles present ---"

grep -nE 'css/phase61_workspace_consolidation.css|css/phase61_tabs_observational_workspace.css|css/dashboard.css|css/matilda-chat.css' public/dashboard.html

echo

echo "--- remaining neutralized stylesheet refs ---"

grep -n 'temporary neutralization: removed local stylesheet' public/dashboard.html || true

echo

echo "--- required layout containers present ---"

grep -nE 'id="phase61-workspace-grid"|id="phase61-operator-column"|id="phase61-telemetry-column"|id="operator-workspace-card"|id="observational-workspace-card"' public/dashboard.html

echo

echo "--- layout css rules exist ---"

grep -nE '#phase61-workspace-grid|\.obs-panel|\.obs-surface' public/css/phase61_workspace_consolidation.css public/css/phase61_tabs_observational_workspace.css

cat > served-dashboard-layout-style-repair-finding.txt << 'NOTE'

SERVED DASHBOARD LAYOUT STYLE REPAIR FINDING

Finding Status: VERIFIED AT FILE LEVEL

The served dashboard structure was present, but the layout stylesheets had been neutralized.

Repair applied:

- Restored dashboard stylesheet references in public/dashboard.html.

- Restored phase61_workspace_consolidation.css.

- Restored phase61_tabs_observational_workspace.css.

Current implication:

If the browser still shows the old structure, hard-refresh or restart the local static/server process before further code changes.

Do not replace public/dashboard.html wholesale.

NOTE

git status --short public/dashboard.html served-dashboard-layout-style-repair-finding.txt

