
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase530_visible_panels_bridge.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

needle = '      const explanation = esc(t.explanation_preview || "");'

replacement = '''      const explanation = esc(t.explanation_preview || "");

      const triageStatusRaw = String(t.status || "").toLowerCase();

      const triageLabel = triageStatusRaw === "completed" ? "triage: completed" : "";'''

if replacement not in text:

    if needle not in text:

        raise SystemExit("Expected explanation_preview anchor not found; aborting.")

    text = text.replace(needle, replacement, 1)

badge_anchor = '            ${retryOf ? `<div style="flex:0 0 auto;color:#fcd34d;border:1px solid rgba(252,211,77,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(120,53,15,.18);">retry of: ${retryOf}</div>` : ""}'

badge_replacement = '''            ${retryOf ? `<div style="flex:0 0 auto;color:#fcd34d;border:1px solid rgba(252,211,77,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(120,53,15,.18);">retry of: ${retryOf}</div>` : ""}

            ${triageLabel ? `<div style="flex:0 0 auto;color:#86efac;border:1px solid rgba(134,239,172,.35);border-radius:999px;padding:2px 7px;font-size:10px;line-height:1.4;background:rgba(22,101,52,.18);">${triageLabel}</div>` : ""}'''

if badge_replacement not in text:

    if badge_anchor not in text:

        raise SystemExit("Expected lineage badge anchor not found; aborting.")

    text = text.replace(badge_anchor, badge_replacement, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase530_visible_panels_bridge.js | grep -q "triage: completed"

open "http://localhost:3000"

git add "$TARGET" PHASE719_COMPLETED_TRIAGE_BADGE.sh

git commit -m "Phase 719: add completed triage badge"

git push origin dev

