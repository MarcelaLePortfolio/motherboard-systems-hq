
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

printf "\n===== PHASE 717 REBUILD AND VALIDATE INSPECTION MODAL =====\n\n"

printf "[1] Confirm source contains inspection modal markers\n"

grep -nE "data-phase717-inspect-details|data-phase717-inspect-trace|phase717InspectionModal|phase717-inspection-modal-root" public/js/phase530_visible_panels_bridge.js

printf "\n[2] Rebuild dashboard so served JS matches source\n"

docker compose up -d --build dashboard

printf "\n[3] Allow dashboard to settle\n"

sleep 5

printf "\n[4] Confirm Docker runtime\n"

docker compose ps

printf "\n[5] Fetch served dashboard and renderer\n"

curl -fsS http://localhost:3000 >/tmp/phase717_modal_rebuild_home.html

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js >/tmp/phase717_modal_rebuild_renderer.js

wc -c /tmp/phase717_modal_rebuild_home.html

wc -c /tmp/phase717_modal_rebuild_renderer.js

printf "\n[6] Confirm served renderer has inspection chips/modal/listener\n"

grep -nE "data-phase717-inspect-details|data-phase717-inspect-trace|phase717InspectionModal|phase717-inspection-modal-root" /tmp/phase717_modal_rebuild_renderer.js

printf "\n[7] Confirm retry controls remain in served renderer\n"

grep -nE "data-phase717-requeue|data-phase717-retry-differently|phase717RetryTask" /tmp/phase717_modal_rebuild_renderer.js

printf "\n[8] Confirm passive placeholder copy is gone from served renderer\n"

if grep -nE "Details available in the read-only audit/evidence surfaces|Advanced trace captured" /tmp/phase717_modal_rebuild_renderer.js; then

  echo "FAIL: passive placeholder copy remains in served renderer."

  exit 1

else

  echo "PASS: passive placeholder copy removed from served renderer."

fi

printf "\n[9] Confirm git state\n"

git status --short

git rev-parse --short HEAD

printf "\n===== PHASE 717 INSPECTION MODAL REBUILD VALIDATION COMPLETE =====\n"

