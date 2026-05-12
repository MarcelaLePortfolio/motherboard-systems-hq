
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''        explanation ? `details=${explanation}` : ""'''

new = '''        ""'''

if new not in text:

    if old not in text:

        raise SystemExit("Expected inline details telemetry anchor not found; aborting.")

    text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

open "http://localhost:3000"

git add "$TARGET" PHASE719_REMOVE_INLINE_DETAILS_TEXT.sh

git commit -m "Phase 719: remove inline details telemetry"

git push origin dev

