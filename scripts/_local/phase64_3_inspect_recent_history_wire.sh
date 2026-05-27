#!/usr/bin/env bash
set -euo pipefail

echo "== inspect phase61_recent_history_wire.js =="
nl -ba public/js/phase61_recent_history_wire.js | sed -n '70,140p'
echo
nl -ba public/js/phase61_recent_history_wire.js | sed -n '140,210p'
echo
grep -n 'buildOwnedShell\|data-phase61-list\|overflowY\|minHeight\|flex = "1 1 auto"' public/js/phase61_recent_history_wire.js || true
