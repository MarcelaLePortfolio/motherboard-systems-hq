#!/bin/bash
set -euo pipefail

FILE="public/js/phase457_restore_task_panels.js"

echo "=== PHASE457 SAFE FIX: MOVE CONNECT TO DOM READY + LAZY ROOT ==="

# 1) Replace static root capture with lazy getter
perl -0777 -i -pe '
s/const root = document\.getElementById\(ROOT_ID\);/function getRoot() { return document.getElementById(ROOT_ID); }/g;
' "$FILE"

# 2) Replace root usage safety (render-time check already exists, reinforce it)
sed -i '' 's/const root = document.getElementById(ROOT_ID);/\/\/ migrated to lazy getRoot()/g' "$FILE"

# 3) Wrap initialization in DOMContentLoaded if not already guarded
if ! grep -q "DOMContentLoaded" "$FILE"; then
cat >> "$FILE" << 'PATCH'

document.addEventListener("DOMContentLoaded", () => {
  render("reconnecting");
  connect();
});
PATCH
fi

# 4) Remove immediate top-level boot if present (avoid double init)
sed -i '' '/render("reconnecting");/d' "$FILE" || true
sed -i '' '/connect();/d' "$FILE" || true

echo "=== PATCH COMPLETE ==="
