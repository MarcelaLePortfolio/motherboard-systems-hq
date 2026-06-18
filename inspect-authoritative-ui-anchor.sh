
#!/usr/bin/env bash

set -euo pipefail

echo "--- current branch / recent UI commits ---"

git branch --show-current

git log --oneline -12 -- public/index.html public/dashboard.html public/js/phase530_visible_panels_bridge.js public/bundle.js 2>/dev/null || true

echo

echo "--- active candidate dashboard HTML files only ---"

find . \( -path './.git' -o -path './node_modules' -o -path './backups' -o -path './_dashboard_candidate_previews' -o -path './DASHBOARD_UI_RECOVERY_ANCHORS' -o -path './scripts_backup' -o -path './scripts_backup_2' -o -path './exports' -o -path './snapshots' \) -prune -o \( -path './public/index.html' -o -path './public/dashboard.html' -o -path './index.html' -o -path './dashboard.html' \) -print | sort

echo

echo "--- explicit UI anchor / recovery anchor references ---"

git grep -nEi "authoritative.*ui|ui.*anchor|anchored.*ui|dashboard.*anchor|current-close-enough|phase530|visible_panels_bridge|served dashboard|canonical dashboard|renderer-authoritative|authoritative dashboard" -- '*.txt' '*.md' '*.mjs' '*.js' '*.html' 2>/dev/null \

  | grep -Ev '^(node_modules|backups|_dashboard_candidate_previews|DASHBOARD_UI_RECOVERY_ANCHORS|scripts_backup|scripts_backup_2|exports|snapshots|public/bundle\.js|public/bundle\.js\.map)/' || true

echo

echo "--- served dashboard route / static serving references ---"

git grep -nEi "sendFile|dashboard.html|index.html|express.static|app.get.*dashboard|app.get.*\/" -- server.mjs server routes '*.mjs' '*.js' 2>/dev/null \

  | grep -Ev '^(backups|scripts_backup|scripts_backup_2)/' || true

echo

echo "--- dashboard script anchors in active public files ---"

grep -nE "phase530_visible_panels_bridge|dashboard-bundle-entry|bundle.js|phase565_recent_tasks_wire|project-visual-output|phase61_tabs_workspace" public/index.html public/dashboard.html || true

