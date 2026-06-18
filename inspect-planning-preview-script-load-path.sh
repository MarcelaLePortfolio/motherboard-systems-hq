
#!/usr/bin/env bash

set -euo pipefail

echo "--- index script tags / module loading ---"

grep -nE "dashboard-bundle-entry|phase61_tabs_workspace|project-visual-output|phase530_visible_panels_bridge|script" public/index.html | head -180

echo

echo "--- dashboard script tags / module loading ---"

grep -nE "dashboard-bundle-entry|phase61_tabs_workspace|project-visual-output|phase530_visible_panels_bridge|script" public/dashboard.html | head -180

echo

echo "--- dashboard bundle entry current imports ---"

cat public/js/dashboard-bundle-entry.js

echo

echo "--- current package build scripts ---"

cat package.json | grep -nE "build|dashboard|bundle|scripts" -A 25

