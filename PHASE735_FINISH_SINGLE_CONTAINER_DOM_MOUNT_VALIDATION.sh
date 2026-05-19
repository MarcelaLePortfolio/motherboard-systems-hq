
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

git add public/js/phase530_visible_panels_bridge.js PHASE735_PATCH_SINGLE_CONTAINER_DOM_MOUNT_AND_ENTITY_DECODE.py PHASE735_SINGLE_CONTAINER_DOM_MOUNT_ENTITY_DECODE.md

git commit -m "Mount single-container visual artifacts as decoded sanitized DOM" || true

git push

docker compose build dashboard

docker compose up -d dashboard

sleep 8

docker compose exec dashboard sh -lc 'grep -n "phase735DecodeVisualArtifactHtmlTransport\|querySelectorAll.*phase735-visual-html-mount\|data-phase735-visual-html-mount" /app/public/js/phase530_visible_panels_bridge.js || true'

git status --short

echo ""

echo "VALIDATE:"

echo "1. Hard refresh browser with CMD+SHIFT+R"

echo "2. Reopen the latest Artifact Garden preview"

echo "3. Confirm whether styled DOM renders instead of div/style text"

