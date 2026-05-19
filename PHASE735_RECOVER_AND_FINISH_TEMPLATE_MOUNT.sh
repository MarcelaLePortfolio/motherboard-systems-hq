
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 PHASE735_PATCH_TEMPLATE_MOUNT_VISUAL_ARTIFACT.py

git diff -- public/js/phase530_visible_panels_bridge.js PHASE735_TEMPLATE_MOUNT_FINDING.md || true

git add public/js/phase530_visible_panels_bridge.js PHASE735_PATCH_TEMPLATE_MOUNT_VISUAL_ARTIFACT.py PHASE735_TEMPLATE_MOUNT_FINDING.md

git commit -m "Use template mount for visual artifact DOM rendering" || true

git push

docker compose build dashboard

docker compose up -d dashboard

sleep 8

docker compose exec dashboard sh -lc 'grep -n "phase735-visual-html-template\|phase735-visual-html-mount" /app/public/js/phase530_visible_panels_bridge.js || true'

git status --short

