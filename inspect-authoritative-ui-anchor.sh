
#!/usr/bin/env bash

set -euo pipefail

echo "--- current branch / recent UI commits ---"

git branch --show-current

git log --oneline -12 -- public/index.html public/dashboard.html public/js/phase530_visible_panels_bridge.js public/bundle.js dashboard.html index.html 2>/dev/null || true

echo

echo "--- candidate dashboard HTML files ---"

find . -maxdepth 4 \

  \( -path './.git' -o -path './node_modules' -o -path './backups' -o -path './_dashboard_candidate_previews' -o -path './DASHBOARD_UI_RECOVERY_ANCHORS' \) -prune -o \

  \( -name 'index.html' -o -name 'dashboard.html' \) -print | sort

echo

echo "--- explicit UI anchor / recovery anchor references ---"

git grep -nEi "authoritative.*ui|ui.*anchor|anchored.*ui|dashboard.*anchor|current-close-enough|phase530|visible_panels_bridge|served dashboard|canonical dashboard|renderer-authoritative|authoritative dashboard" -- \

  '*.txt' '*.md' '*.mjs' '*.js' '*.html' \

  ':!node_modules/**' \

  ':!backups/**' \

  ':!_dashboard_candidate_previews/**' || true

echo

echo "--- served routes for dashboard/index ---"

git grep -nE "sendFile|res\.send|dashboard\.html|index\.html|express\.static|/dashboard|app\.get" -- server.mjs server routes '*.mjs' '*.js' 2>/dev/null || true

echo

echo "--- active UI script load fingerprints ---"

for f in public/index.html public/dashboard.html index.html dashboard.html; do

  if [ -f "$f" ]; then

    echo

    echo "===== $f ====="

    grep -nE "phase530_visible_panels_bridge|dashboard-bundle-entry|bundle.js|phase565_recent_tasks_wire|project-visual-output|phase61_tabs_workspace" "$f" || true

  fi

done

echo

echo "--- tracked UI files with recent modification metadata ---"

git ls-files | grep -E '(^public/(index|dashboard)\.html$|^public/js/phase530_visible_panels_bridge\.js$|^public/bundle\.js$|dashboard\.html$|index\.html$)' | while read -r f; do

  [ -f "$f" ] && stat -f "%Sm %N" -t "%Y-%m-%d %H:%M:%S" "$f"

done

