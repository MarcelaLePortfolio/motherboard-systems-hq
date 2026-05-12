
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 INSPECT CHAT REPLY BLOCK ====="

echo ""

echo "[1] server.js reply block"

nl -ba server.js | sed -n '540,640p'

echo ""

echo "[2] server.mjs reply block"

nl -ba server.mjs | sed -n '575,675p'

echo ""

echo "[3] Repo status"

git status --short

echo ""

echo "===== INSPECTION COMPLETE ====="

git add PHASE719_INSPECT_CHAT_REPLY_BLOCK.sh

git commit -m "Phase 719: inspect chat reply block"

git push origin dev

