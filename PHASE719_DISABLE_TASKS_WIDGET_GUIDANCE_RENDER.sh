
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/dashboard-tasks-widget.js"

echo "===== PHASE 719 DISABLE TASKS WIDGET GUIDANCE RENDER ====="

python3 - <<'PY'

from pathlib import Path

import re

path = Path("public/js/dashboard-tasks-widget.js")

text = path.read_text()

if "PHASE719_TASKS_WIDGET_GUIDANCE_DISABLED" in text:

    print("guidance renderer already disabled")

    raise SystemExit(0)

pattern = re.compile(

    r'''function renderGuidance\(t\)\s*\{.*?^\s*\}''',

    re.DOTALL | re.MULTILINE

)

replacement = '''function renderGuidance(t) {

    // PHASE719_TASKS_WIDGET_GUIDANCE_DISABLED

    // Guidance/details rendering intentionally disabled.

    // phase530_visible_panels_bridge.js is authoritative.

    return "";

  }'''

text_new, count = pattern.subn(replacement, text, count=1)

if count != 1:

    raise SystemExit("Expected renderGuidance function not found exactly once; aborting.")

path.write_text(text_new)

print("patched renderGuidance successfully")

PY

node --check "$TARGET"

grep -n "PHASE719_TASKS_WIDGET_GUIDANCE_DISABLED" "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

open "http://localhost:3000"

git add "$TARGET" PHASE719_DISABLE_TASKS_WIDGET_GUIDANCE_RENDER.sh

git commit -m "Phase 719: disable tasks widget guidance renderer"

git push origin dev

echo ""

echo "===== PHASE 719 GUIDANCE RENDER DISABLED ====="

