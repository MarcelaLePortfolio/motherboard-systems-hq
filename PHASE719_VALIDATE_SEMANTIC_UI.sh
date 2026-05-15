
#!/bin/bash

set -euo pipefail

echo "===== PHASE 719 SEMANTIC UI VALIDATION ====="

git status --short

git log --oneline --decorate -3

node --check public/js/phase530_visible_panels_bridge.js

docker ps --format "table {{.Names}}\t{{.Status}}" | head

curl -sS http://localhost:3000/ | head -5 || true

echo "===== COMPLETE ====="

