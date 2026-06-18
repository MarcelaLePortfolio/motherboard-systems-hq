
#!/usr/bin/env bash

set -euo pipefail

echo "--- latest layout repair commits ---"

git log --oneline -5

echo

echo "--- served dashboard now has live layout css links ---"

grep -nE 'css/dashboard.css|css/phase61_workspace_consolidation.css|css/phase61_tabs_observational_workspace.css' public/dashboard.html

echo

echo "--- suggested browser check ---"

cat << 'NOTE'

Open /dashboard and hard-refresh:

Mac Chrome/Edge:

Cmd+Shift+R

Mac Safari:

Option+Cmd+E, then Cmd+R

Expected change:

The dashboard should stop looking structurally flattened/broken because phase61 workspace/grid/tab CSS is loaded again.

NOTE

