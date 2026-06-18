
#!/usr/bin/env bash

set -euo pipefail

echo "--- route authority ---"

grep -nE 'app.get\("/dashboard"|app.get\("/"|sendFile|redirect' server.mjs

echo

echo "--- dashboard recovery / authority docs ---"

git grep -nEi "authoritative dashboard|served dashboard|canonical dashboard|dashboard authority|public/dashboard.html|public/index.html|renderer-authoritative|current-close-enough|phase91|phase88_11" -- \

  '*.txt' '*.md' '*.mjs' '*.js' '*.html' \

  ':!node_modules/**' \

  ':!backups/**' \

  ':!scripts_backup/**' \

  ':!scripts_backup_2/**' \

  ':!snapshots/**' \

  ':!public/bundle.js' \

  ':!public/bundle.js.map' || true

echo

echo "--- active dashboard script delta ---"

grep -nE "phase530_visible_panels_bridge|phase565_recent_tasks_wire|phase61_tabs_workspace|project-visual-output|dashboard-bundle-entry|bundle.js" public/index.html public/dashboard.html public/js/dashboard-bundle-entry.js || true

