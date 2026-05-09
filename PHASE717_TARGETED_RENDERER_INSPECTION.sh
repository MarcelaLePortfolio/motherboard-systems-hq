
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

printf "\n===== PHASE 717 TARGETED RENDERER INSPECTION =====\n\n"

printf "[1] Baseline\n"

git rev-parse --short HEAD

git status --short

printf "\n[2] Confirm runtime\n"

docker compose ps

curl -fsS http://localhost:3000 >/tmp/phase717_dashboard_targeted.html

wc -c /tmp/phase717_dashboard_targeted.html

printf "\n[3] Inspect confirmed renderer bridge only\n"

sed -n '1,340p' public/js/phase530_visible_panels_bridge.js

printf "\n[4] Search confirmed public JS only\n"

grep -RInE "Recent Tasks|Retry differently|Requeue|operator-actions|advanced|Advanced|details|Details|evidence|Evidence" public/js 2>/dev/null || true

printf "\n===== PHASE 717 TARGETED RENDERER INSPECTION COMPLETE =====\n"

