
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

if "const phase718TaskTitleByKey = new Map();" not in text:

    marker = ".map((t) => {"

    idx = text.find(marker)

    if idx == -1:

        raise SystemExit("Could not locate task map renderer anchor; aborting.")

    line_start = text.rfind("\n", 0, idx) + 1

    insert = '''      const phase718TaskTitleByKey = new Map();

      tasks.forEach((taskForTitle) => {

        const readableTitle = String(taskForTitle.title || taskForTitle.task_title || taskForTitle.task_id || taskForTitle.id || "");

        const keys = [

          taskForTitle.task_id,

          taskForTitle.id,

          taskForTitle.uuid,

          taskForTitle.execution_id

        ].filter(Boolean).map(String);

        keys.forEach((key) => {

          if (key && readableTitle) {

            phase718TaskTitleByKey.set(key, readableTitle);

          }

        });

      });

'''

    text = text[:line_start] + insert + text[line_start:]

old = '''      const operatorTitle = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : rawTitle;

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);'''

new = '''      const operatorAction = retryTitleMatch

        ? (retryTitleMatch[1].toLowerCase() === "requeue" ? "Requeue" : "Retry differently")

        : "";

      const operatorTarget = retryTitleMatch ? retryTitleMatch[2] : "";

      const resolvedTargetTitleRaw = operatorTarget && phase718TaskTitleByKey.has(operatorTarget)

        ? phase718TaskTitleByKey.get(operatorTarget)

        : operatorTarget;

      const operatorTitle = operatorAction && resolvedTargetTitleRaw

        ? `${operatorAction}: ${resolvedTargetTitleRaw}`

        : (operatorAction || rawTitle);

      const title = esc(operatorTitle);

      const targetTitle = esc(operatorTarget);'''

if new not in text:

    if old not in text:

        raise SystemExit("Expected operator title block not found; aborting.")

    text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

echo "Retry target title resolution anchors:"

grep -nE "phase718TaskTitleByKey|resolvedTargetTitleRaw|operatorAction|operatorTitle" "$TARGET" | head -30

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q "phase718TaskTitleByKey"

echo "dashboard + target title renderer: PASS"

open "http://localhost:3000"

git add "$TARGET" PHASE718_RESOLVE_RETRY_TARGET_TITLES.sh

git commit -m "Phase 718: resolve retry target task titles"

git push origin dev

