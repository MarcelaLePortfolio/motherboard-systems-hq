
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

cat > PHASE717_INSPECTION_MODAL_ANCHOR_DISCOVERY.md << 'NOTE'

# Phase 717 Inspection Modal Anchor Discovery

Purpose:

- Stop speculative inspection-modal patching after two safe refusals.

- Identify the exact event-listener/control-binding shape in public/js/phase530_visible_panels_bridge.js.

- Preserve the current stable checkpoint before retrying the implementation.

Current checkpoint:

- HEAD expected: b25e7532 or later

- External backup captured source-b25e7532.tar.gz

- No successful inspection-modal source mutation has been committed yet

Next rule:

- Do not attempt the modal patch again until the exact click-binding anchor is confirmed from source output.

NOTE

printf "\n===== PHASE 717 INSPECTION MODAL ANCHOR DISCOVERY =====\n\n"

printf "[1] Baseline\n"

git rev-parse --short HEAD

git status --short

printf "\n[2] Renderer tail/control-binding section\n"

nl -ba public/js/phase530_visible_panels_bridge.js | sed -n '360,480p'

printf "\n[3] Listener/control binding search\n"

grep -nE "addEventListener|onclick|phase717RetryTask|data-phase717-requeue|data-phase717-retry-differently|closest" public/js/phase530_visible_panels_bridge.js || true

printf "\n[4] Confirm no inspection modal has been inserted\n"

if grep -nE "phase717InspectionModal|data-phase717-inspect-details|data-phase717-inspect-trace|phase717-inspection-modal-root" public/js/phase530_visible_panels_bridge.js; then

  echo "Inspection modal/chip markers already present."

else

  echo "PASS: no inspection modal/chip markers currently present in active renderer."

fi

printf "\n[5] Runtime still healthy\n"

docker compose ps

curl -fsS http://localhost:3000 >/tmp/phase717_anchor_discovery_home.html

wc -c /tmp/phase717_anchor_discovery_home.html

printf "\n===== PHASE 717 INSPECTION MODAL ANCHOR DISCOVERY COMPLETE =====\n"

