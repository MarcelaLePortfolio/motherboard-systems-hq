
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 720 SEMANTIC PATH INSPECTION ====="

echo ""

echo "[1] Current branch and HEAD"

git branch --show-current

git log --oneline --decorate -5

echo ""

echo "[2] Working tree status"

git status --short

echo ""

echo "[3] Artifact route references"

grep -RIn "artifact-preview\|artifacts" routes server worker src public api 2>/dev/null || true

echo ""

echo "[4] Worker artifact generation references"

grep -RIn "writeFile\|artifact\|markdown\|completed" worker src server routes 2>/dev/null | head -200 || true

echo ""

echo "[5] Frontend semantic renderer references"

grep -RIn "semantic\|artifact preview\|Preview\|artifact-preview\|section" public/js 2>/dev/null | head -240 || true

echo ""

echo "[6] Existing artifact files"

find . -path "./node_modules" -prune -o -path "./.git" -prune -o -iname "*artifact*" -print | head -200

echo ""

echo "[7] Docker runtime status"

docker ps

echo ""

echo "===== PHASE 720 SEMANTIC PATH INSPECTION COMPLETE ====="

