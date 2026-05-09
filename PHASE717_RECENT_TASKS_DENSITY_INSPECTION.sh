
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

printf "\n===== PHASE 717 RECENT TASKS DENSITY INSPECTION =====\n\n"

printf "[1] Confirm baseline\n"

git rev-parse --short HEAD

git status --short

printf "\n[2] Locate Recent Tasks renderer files and lifecycle markers\n"

find public scripts app src routes -type f 2>/dev/null \

  | grep -v "/node_modules/" \

  | grep -v "/.git/" \

  | grep -v ".tar.gz$" \

  | xargs grep -nE "Recent Tasks|recent tasks|operator-actions|Retry differently|Requeue|advanced JSON|task-card|task card|execution-evidence" 2>/dev/null \

  | head -n 200 || true

printf "\n[3] Inspect likely renderer bridge file\n"

sed -n '1,260p' public/js/phase530_visible_panels_bridge.js

printf "\n[4] Confirm dashboard runtime still healthy\n"

docker compose ps

curl -fsS http://localhost:3000 >/tmp/phase717_dashboard_home.html

printf "dashboard_home_bytes="

wc -c </tmp/phase717_dashboard_home.html

printf "\n[5] Capture candidate density terms from served dashboard\n"

grep -nE "Advanced|advanced|details|Details|evidence|Evidence|logs|Logs|Retry differently|Requeue" /tmp/phase717_dashboard_home.html \

  | head -n 120 || true

printf "\n===== PHASE 717 RECENT TASKS DENSITY INSPECTION COMPLETE =====\n"

