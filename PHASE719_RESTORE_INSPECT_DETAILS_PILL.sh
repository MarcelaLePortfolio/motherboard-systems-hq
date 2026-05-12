
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''          ${explanation ? "" : ""}'''

new = '''          ${explanation ? `<button type="button" data-phase717-inspect-details="true" data-phase717-inspect-title="${title} — Details" data-phase717-inspect-content="${explanation}" style="margin-top:10px;cursor:pointer;border:1px solid rgba(147,197,253,.35);background:rgba(30,64,175,.14);color:#93c5fd;border-radius:999px;padding:4px 9px;font-size:11px;">Inspect details</button>` : ""}'''

if old not in text:

    raise SystemExit("Expected suppressed inspect-details block not found; aborting.")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q "Inspect details"

open "http://localhost:3000"

git add "$TARGET" PHASE719_RESTORE_INSPECT_DETAILS_PILL.sh

git commit -m "Phase 719: restore inspect details pill"

git push origin dev

