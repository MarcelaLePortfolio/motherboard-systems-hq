
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

rm -f PHASE719_CARD_HIERARCHY_REFINEMENT.sh

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''          <div style="margin-top:4px;color:#94a3b8;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">status=${status} · id=${taskId}</div>'''

new = '''          <div style="margin-top:4px;color:#94a3b8;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">${triageLabel ? `id=${taskId}` : `status=${status} · id=${taskId}`}</div>'''

if new not in text:

    if old not in text:

        raise SystemExit("Expected duplicate status metadata row not found; aborting.")

    text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q 'triageLabel ? `id=${taskId}`'

open "http://localhost:3000"

git add "$TARGET" PHASE719_REMOVE_DUPLICATE_STATUS_METADATA.sh

git commit -m "Phase 719: remove duplicate status metadata"

git push origin dev
