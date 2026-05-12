
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

rm -f PHASE719_SUPPRESS_DETAILS_META_LINE.sh

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''          ${outcome ? `<div style="margin-top:8px;color:#94a3b8;font-size:11px;overflow-wrap:anywhere;word-break:break-word;">Outcome available in Inspect logs.</div>` : ""}'''

new = '''          ${outcome ? "" : ""}'''

if new not in text:

    if old not in text:

        raise SystemExit("Expected inline outcome hint not found; aborting.")

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

git add "$TARGET" PHASE719_REMOVE_INLINE_OUTCOME_HINT.sh

git commit -m "Phase 719: remove inline outcome hint"

git push origin dev

