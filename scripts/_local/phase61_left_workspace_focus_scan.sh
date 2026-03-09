#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '\n=== dashboard.html: operator + observational workspace slice ===\n'
nl -ba public/dashboard.html | sed -n '100,280p'

printf '\n=== dashboard tab wiring across active dashboard files ===\n'
rg -n 'observational-tabs|obs-tab|obs-panel|data-target|aria-controls|aria-selected|mb-task-events-panel-anchor' \
  public/dashboard.html public/dashboard.js public/js/*.js || true

printf '\n=== dashboard-tabs.js: legacy tab wiring slice ===\n'
if [ -f public/dashboard-tabs.js ]; then
  nl -ba public/dashboard-tabs.js | sed -n '1,240p'
fi

printf '\n=== dashboard-tabs.backup.js: legacy tab wiring hits ===\n'
if [ -f public/dashboard-tabs.backup.js ]; then
  rg -n 'obs-tab|obs-panel|tablist|aria-selected|data-target|hidden|tabpanel' public/dashboard-tabs.backup.js || true
fi

exit 0
