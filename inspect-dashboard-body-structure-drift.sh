
#!/usr/bin/env bash

set -euo pipefail

TMP_DIR="$(mktemp -d)"

trap 'rm -rf "$TMP_DIR"' EXIT

dashboard_body="$TMP_DIR/dashboard-body.txt"

index_body="$TMP_DIR/index-body.txt"

dashboard_scripts="$TMP_DIR/dashboard-scripts.txt"

index_scripts="$TMP_DIR/index-scripts.txt"

echo "--- current head ---"

git log --oneline -6

echo

echo "--- focused workspace body diff dashboard vs index ---"

sed -n '/<section id="phase61-workspace-shell"/,/<section id="phase61-atlas-band"/p' public/dashboard.html > "$dashboard_body" || true

sed -n '/<section id="phase61-workspace-shell"/,/<section id="atlas-status-card"/p' public/index.html > "$index_body" || true

diff -u "$dashboard_body" "$index_body" | sed -n '1,260p' || true

echo

echo "--- focused script diff dashboard vs index ---"

grep -nE '<script|</script>|phase61_tabs_workspace|phase530_visible_panels_bridge|phase565_recent_tasks_wire|dashboard-bundle-entry|task-events-sse-client|dashboard-delegation|operatorGuidance|phase457|phase489|phase490|phase531|phase533|phase534|phase535|phase537|phase539' public/dashboard.html > "$dashboard_scripts" || true

grep -nE '<script|</script>|phase61_tabs_workspace|phase530_visible_panels_bridge|phase565_recent_tasks_wire|dashboard-bundle-entry|task-events-sse-client|dashboard-delegation|operatorGuidance|phase457|phase489|phase490|phase531|phase533|phase534|phase535|phase537|phase539' public/index.html > "$index_scripts" || true

diff -u "$dashboard_scripts" "$index_scripts" | sed -n '1,260p' || true

echo

echo "--- CSS rules touching workspace grid/card layout ---"

grep -RInE '#phase61-workspace-grid|#phase61-operator-column|#phase61-telemetry-column|#operator-workspace-card|#observational-workspace-card|#operator-panels|#observational-panels|\.obs-panel|\.obs-surface' public/css public/dashboard.html public/js \

  --exclude='bundle.js' --exclude='bundle.js.map' \

  | sed -n '1,260p' || true

cat > dashboard-still-wrong-structure-finding.txt << 'NOTE'

DASHBOARD STRUCTURE STILL WRONG FINDING

Finding Status: ACTIVE

The JavaScript syntax blocker has been repaired, but the browser still shows an incorrect dashboard structure.

Current interpretation:

- Do not continue adding Planning Preview behavior.

- Do not replace public/dashboard.html wholesale.

- The next safe move is focused structure/style drift inspection between the served dashboard and the known restored index surface.

NOTE

echo

echo "--- focused git status ---"

git status --short inspect-dashboard-body-structure-drift.sh dashboard-body-structure-drift-report.txt dashboard-still-wrong-structure-finding.txt

