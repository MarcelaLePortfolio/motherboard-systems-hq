
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 INSPECT MATILDA PROMPT BLOCK ====="

echo ""

echo "[1] server.js advisory prompt window"

nl -ba server.js | sed -n '384,430p'

echo ""

echo "[2] server.mjs advisory prompt window"

nl -ba server.mjs | sed -n '417,463p'

echo ""

echo "[3] Runtime verification"

curl -fsS http://localhost:3000 >/dev/null && echo "dashboard: PASS"

echo ""

echo "[4] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_INSPECT_MATILDA_PROMPT_BLOCK.sh

git commit -m "Phase 719: inspect Matilda advisory prompt block"

git push origin dev

