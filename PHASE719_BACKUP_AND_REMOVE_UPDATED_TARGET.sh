
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 719 BACKUP + REMOVE INLINE TEXT ====="

echo "[1] Seal checkpoint"

git tag -f phase719-inspect-pill-restored

git push origin phase719-inspect-pill-restored --force

echo ""

echo "[2] External archive backup"

./PHASE715_EXTERNAL_ARCHIVE_BACKUP.sh

echo ""

echo "[3] Remove remaining inline metadata text"

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

replacements = [

(

'''          ${updated ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">updated=${updated}</div>` : ""}''',

'''          ${""}'''

),

(

'''          ${targetTitle ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">target=${targetTitle}</div>` : ""}''',

'''          ${""}'''

)

]

for old, new in replacements:

    if old not in text:

        raise SystemExit(f"Expected inline metadata block not found:\\n{old}")

    text = text.replace(old, new, 1)

path.write_text(text)

print("removed updated/target inline text")

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

echo ""

echo "[4] Validate served renderer"

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -nE "updated=|target=" || true

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q "Inspect details"

open "http://localhost:3000"

git add "$TARGET" PHASE719_BACKUP_AND_REMOVE_UPDATED_TARGET.sh

git commit -m "Phase 719: remove updated and target inline text"

git push origin dev

echo ""

echo "===== PHASE 719 INLINE TEXT CLEANUP COMPLETE ====="

