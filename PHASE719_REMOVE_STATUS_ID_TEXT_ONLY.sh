
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

echo "===== PHASE 719 REMOVE STATUS/ID TEXT ONLY ====="

python3 - <<'PY'

from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

pattern = re.compile(

    r'\n\s*<div style="margin-top:4px;color:#94a3b8;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">\$\{triageLabel \? `id=\$\{taskId\}` : `status=\$\{status\} · id=\$\{taskId\}`\}</div>\n',

    re.MULTILINE,

)

text_new, count = pattern.subn('\n            ${""}\n', text, count=1)

if count != 1:

    raise SystemExit("Expected status/id line not found exactly once; aborting.")

path.write_text(text_new)

print("removed status/id inline text")

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

open "http://localhost:3000"

git add "$TARGET" PHASE719_REMOVE_STATUS_ID_TEXT_ONLY.sh

git commit -m "Phase 719: remove status and id inline text"

git push origin dev

echo "===== PHASE 719 STATUS/ID TEXT REMOVED ====="

