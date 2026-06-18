
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

p = Path("public/js/dashboard-bundle-entry.js")

s = p.read_text()

imports = [

    'import "./phase61_tabs_workspace.js";',

    'import "./phase530_visible_panels_bridge.js";',

]

for line in imports:

    if line not in s:

        s = s.rstrip() + "\n\n" + line + "\n"

p.write_text(s)

PY

node --check public/js/dashboard-bundle-entry.js

grep -nE 'phase61_tabs_workspace|phase530_visible_panels_bridge|planning-preview-card' public/js/dashboard-bundle-entry.js

docker compose build dashboard

docker compose up -d dashboard

cat > telemetry-tabs-repair-finding.txt << 'NOTE'

TELEMETRY TABS REPAIR FINDING

Finding Status: APPLIED

The served dashboard structure was restored, but the telemetry panels were all visible because the served dashboard bundle did not load the workspace tab controller.

Repair applied:

- Added phase61_tabs_workspace.js to dashboard-bundle-entry.js.

- Added phase530_visible_panels_bridge.js to preserve the restored visible panel bridge.

- Rebuilt and restarted the Docker dashboard service because public assets are copied into the image.

Expected result:

Only the selected telemetry tab panel should be visible.

NOTE

git add public/js/dashboard-bundle-entry.js repair-served-dashboard-telemetry-tabs.sh telemetry-tabs-repair-finding.txt

git commit -m "Repair served dashboard telemetry tabs"

git push

