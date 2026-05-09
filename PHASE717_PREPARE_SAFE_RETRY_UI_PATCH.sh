
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 SAFE RETRY UI PATCH PREP ====="

echo ""

echo "[1] Current checkpoint"

git status --short

git log --oneline --decorate -3

echo ""

echo "[2] Create safety backup of renderer"

cp public/js/phase530_visible_panels_bridge.js public/js/phase530_visible_panels_bridge.js.bak_phase717_retry_ui

echo "backup created:"

ls -lh public/js/phase530_visible_panels_bridge.js.bak_phase717_retry_ui

echo ""

echo "[3] Confirm retry contract route"

grep -n "app.post(\"/api/delegate-task\"" server.js

grep -n "routeRetryExecution" server/retry_execution_router.js

grep -n "enforceRetryContract" server/retry_contract.js

echo ""

echo "[4] Confirm current placeholders remain disabled before patch"

grep -n "disabled title=\"Retry/requeue endpoint contract not confirmed yet\"" public/js/phase530_visible_panels_bridge.js

grep -n "disabled title=\"Strategy-shift retry contract not confirmed yet\"" public/js/phase530_visible_panels_bridge.js

echo ""

echo "===== READY FOR NARROW PATCH ====="

