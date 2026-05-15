
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 SEMANTIC ARTIFACT START ====="

echo ""

echo "[1] Confirm branch and repo state"

git branch --show-current

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Confirm Docker runtime health"

docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "[3] Confirm dashboard route"

curl -sS http://localhost:3000/ | head -20 || true

echo ""

echo "[4] Locate artifact preview and rendering code"

grep -R "artifact-preview\|Preview\|iframe\|srcdoc\|artifact" -n \

  public/js/phase530_visible_panels_bridge.js \

  server.js \

  routes \

  public \

  2>/dev/null | head -200 || true

echo ""

echo "[5] Show current artifact renderer context"

grep -n "artifact-preview\|iframe\|srcdoc\|renderArtifact\|Preview" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[6] Confirm no mutation has been made"

git status --short

echo ""

echo "===== PHASE 719 SEMANTIC ARTIFACT START COMPLETE ====="

