
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

printf "\n===== PHASE 717 VALIDATE COMPACT RECENT TASKS =====\n\n"

printf "[1] Confirm HEAD and clean status\n"

git rev-parse --short HEAD

git status --short

printf "\n[2] Confirm runtime health\n"

docker compose ps

printf "\n[3] Confirm dashboard responds\n"

curl -fsS http://localhost:3000 >/tmp/phase717_compact_validation_home.html

wc -c /tmp/phase717_compact_validation_home.html

printf "\n[4] Confirm served dashboard references current renderer\n"

grep -n "phase530_visible_panels_bridge.js" /tmp/phase717_compact_validation_home.html || true

printf "\n[5] Confirm compact markers exist in renderer source\n"

grep -nE "data-phase717-compact-details|data-phase717-compact-advanced-trace" public/js/phase530_visible_panels_bridge.js

printf "\n[6] Confirm inline advanced JSON card label removed from active renderer\n"

if grep -n "advanced JSON" public/js/phase530_visible_panels_bridge.js; then

  echo "FAIL: inline advanced JSON label remains in active renderer."

  exit 1

else

  echo "PASS: inline advanced JSON label removed from active renderer."

fi

printf "\n[7] Confirm retry controls remain active in renderer\n"

grep -nE "data-phase717-requeue|data-phase717-retry-differently|phase717RetryTask" public/js/phase530_visible_panels_bridge.js

printf "\n===== PHASE 717 COMPACT RECENT TASKS VALIDATION COMPLETE =====\n"

