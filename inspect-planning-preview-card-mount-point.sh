
#!/usr/bin/env bash

set -euo pipefail

echo "--- observational workspace mount structure ---"

sed -n '367,414p' public/index.html

echo

echo "--- dashboard observational workspace mount structure ---"

sed -n '170,214p' public/dashboard.html

echo

echo "--- tab wiring assumptions ---"

sed -n '1,180p' public/js/phase61_tabs_workspace.js

echo

echo "--- bundle entrypoint scripts around dashboard JS imports ---"

sed -n '1,80p' public/js/dashboard-bundle-entry.js

echo

echo "--- existing artifact consumer only dispatches event ---"

sed -n '1,120p' public/js/project-visual-output.js

