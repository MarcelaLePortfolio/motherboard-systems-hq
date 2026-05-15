
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 SEMANTIC ARTIFACT START ====="

git branch --show-current

git status --short

docker ps --format "table {{.Names}}\t{{.Status}}" | head

grep -n "artifact-preview\|iframe\|srcdoc\|renderArtifact\|Preview" \

public/js/phase530_visible_panels_bridge.js | head -40 || true

echo "===== COMPLETE ====="

