
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/dashboard-tasks-widget.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/dashboard-tasks-widget.js")

lines = path.read_text().splitlines()

marker = "PHASE719_TASKS_WIDGET_GUIDANCE_DETAILS_DISABLED"

if any(marker in line for line in lines):

    print("renderGuidance already disabled")

else:

    start = None

    end = None

    for i, line in enumerate(lines):

        if line.strip() == "function renderGuidance(t) {":

            start = i

            break

    if start is None:

        raise SystemExit("renderGuidance start not found; aborting.")

    for j in range(start + 1, len(lines)):

        if lines[j].strip().startswith("async function apiJson"):

            end = j

            break

    if end is None:

        raise SystemExit("apiJson boundary not found; aborting.")

    replacement = [

        "  function renderGuidance(t) {",

        "    // PHASE719_TASKS_WIDGET_GUIDANCE_DETAILS_DISABLED",

        "    // Guidance/details rendering is intentionally suppressed here.",

        "    // phase530_visible_panels_bridge.js owns Recent Tasks lifecycle visibility.",

        '    return "";',

        "  }",

        "",

    ]

    lines[start:end] = replacement

    path.write_text("\\n".join(lines) + "\\n")

    print("patched renderGuidance")

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/dashboard-tasks-widget.js | grep -q "PHASE719_TASKS_WIDGET_GUIDANCE_DETAILS_DISABLED"

open "http://localhost:3000"

git add "$TARGET" PHASE719_DISABLE_TASKS_WIDGET_GUIDANCE_DETAILS.sh

git commit -m "Phase 719: disable tasks widget guidance details"

git push origin dev

