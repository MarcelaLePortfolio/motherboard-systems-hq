
#!/usr/bin/env bash

set -euo pipefail

echo "--- governed planning route response shape ---"

grep -nE "res\.status|res\.json|bundle|approval|artifact|task_record|planning_only|planning_completed" server/routes/governed-planning-route.mjs

echo

echo "--- dashboard mounted panel/card ids ---"

grep -nEi "id=|Execution Inspector|Operator Guidance|Recent Tasks|approval|artifact|planning|review" public/index.html public/dashboard.html | head -220

echo

echo "--- phase530 likely card/panel builders ---"

grep -nEi "execution inspector|operator guidance|artifact|approval|required|review|planning|panel|card" public/js/phase530_visible_panels_bridge.js | head -220

echo

echo "--- governed planning frontend consumers if any ---"

git grep -nEi "governed-planning|planning_record|approval_required|governed_planning|planning artifact|artifact_bundle" -- public/js public/index.html public/dashboard.html ':!public/bundle.js' ':!public/bundle.js.map' || true

