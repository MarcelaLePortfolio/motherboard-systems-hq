#!/usr/bin/env bash
set -euo pipefail

echo "== Phase 65 focused inspection: Tasks Running / Success Rate hooks =="

echo
echo "-- dashboard HTML metric tile hooks --"
nl -ba public/dashboard.html | sed -n '1,260p' | grep -nE 'Tasks Running|Success Rate|Latency|task-count|success-rate|latency|metric|tile' || true

echo
echo "-- agent-status-row.js relevant section --"
nl -ba public/js/agent-status-row.js | sed -n '360,620p'

echo
echo "-- bundle entry confirms mount path --"
nl -ba public/js/dashboard-bundle-entry.js | sed -n '1,80p'

echo
echo "-- recent history wire (to avoid duplicate hydration) --"
nl -ba public/js/phase61_recent_history_wire.js | sed -n '1,260p' || true

echo
echo "-- tabs workspace (to avoid lifecycle collision) --"
nl -ba public/js/phase61_tabs_workspace.js | sed -n '1,260p' || true

echo
echo "Focused inspection complete."
