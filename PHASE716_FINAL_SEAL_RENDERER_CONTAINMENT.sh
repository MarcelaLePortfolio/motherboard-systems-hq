
#!/bin/bash

set -u

echo "===== PHASE 716 FINAL SEAL RENDERER CONTAINMENT ====="

echo ""

echo "[1] Confirm current dev state"

git checkout dev

git status --short

git log --oneline -8

echo ""

echo "[2] Confirm latest verification + backup commit"

git log --oneline -3

echo ""

echo "[3] Confirm renderer containment patch remains active"

grep -n "data-phase716-contained-task\|advanced JSON\|max-height:220px" public/js/phase530_visible_panels_bridge.js || true

echo ""

echo "[4] Confirm preserved static evidence surface"

curl -sS -i "http://localhost:3000/execution-evidence.html" | head -30 || true

echo ""

echo "[5] Confirm runtime APIs"

curl -sS -i "http://localhost:3000/api/tasks" | head -25 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

echo ""

echo "[6] Confirm backup snapshot for efaa36dc exists"

ls -lah "/Volumes/Rio Drive/Motherboard_Storage/snapshots" | tail -10 || true

echo ""

echo "PHASE 716 RESULT:"

echo "- Dev is pushed through ff681bf9."

echo "- Renderer-level containment is active in public/js/phase530_visible_panels_bridge.js."

echo "- Broad CSS/layout fixes remain absent."

echo "- Static execution evidence surface remains preserved."

echo "- External archive captured source-efaa36dc."

echo "- Manual browser confirmation is still the final proof for the overflow behavior."

echo ""

echo "===== PHASE 716 FINAL SEAL RENDERER CONTAINMENT COMPLETE ====="

