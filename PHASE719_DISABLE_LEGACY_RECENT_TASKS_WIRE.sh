
#!/usr/bin/env bash

set -euo pipefail

TARGET="public/js/phase565_recent_tasks_wire.js"

python3 - <<'PY'

from pathlib import Path

path = Path("public/js/phase565_recent_tasks_wire.js")

text = path.read_text()

marker = "PHASE719_LEGACY_RECENT_TASKS_DISABLED"

if marker in text:

    print("Legacy renderer already disabled.")

    raise SystemExit(0)

old = '''  async function refreshRecentTasks() {'''

new = '''  // PHASE719_LEGACY_RECENT_TASKS_DISABLED

  // Legacy Recent Tasks renderer intentionally disabled.

  // phase530_visible_panels_bridge.js is now authoritative.

  async function refreshRecentTasks() {

    return;

'''

if old not in text:

    raise SystemExit("Expected refreshRecentTasks anchor not found; aborting.")

text = text.replace(old, new, 1)

path.write_text(text)

PY

node --check "$TARGET"

docker compose build dashboard

docker compose up -d dashboard

sleep 8

curl -fsS http://localhost:3000 >/dev/null

curl -fsS http://localhost:3000/api/tasks >/dev/null

curl -fsS http://localhost:3000/js/phase565_recent_tasks_wire.js | grep -q "PHASE719_LEGACY_RECENT_TASKS_DISABLED"

open "http://localhost:3000"

git add "$TARGET" PHASE719_DISABLE_LEGACY_RECENT_TASKS_WIRE.sh

git commit -m "Phase 719: disable legacy recent tasks renderer"

git push origin dev

