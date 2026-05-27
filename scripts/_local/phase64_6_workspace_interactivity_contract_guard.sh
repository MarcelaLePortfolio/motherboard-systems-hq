#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${BASE_URL:-http://127.0.0.1:8080}"
STAMP="$(date +%s)"

echo "== repo root =="
pwd
echo

echo "== git head =="
git rev-parse --short HEAD
echo

echo "== dashboard health =="
curl -fsSI "${BASE_URL}/dashboard"
echo

echo "== required upstream task-events guard =="
bash scripts/_local/phase64_5_task_events_contract_guard.sh
echo

echo "== dashboard tab / panel anchors =="
python3 <<'PY'
from pathlib import Path
import re

text = Path("public/dashboard.html").read_text()

checks = {
    "observational-panels": r'id="observational-panels"',
    "operator-panels": r'id="operator-panels"',
    "task-events-card": r'id="task-events-card"',
    "task-events-anchor": r'id="mb-task-events-panel-anchor"',
    "phase61-tabs-workspace-script": r'js/phase61_tabs_workspace\.js',
    "phase61-recent-history-wire": r'js/phase61_recent_history_wire\.js',
}

failed = False
for name, pattern in checks.items():
    ok = re.search(pattern, text) is not None
    print(f"{'PASS' if ok else 'FAIL'}: {name}")
    if not ok:
        failed = True

if failed:
    raise SystemExit(1)
PY
echo

echo "== live dashboard script tags =="
curl -fsS "${BASE_URL}/dashboard" | grep -n 'phase61_recent_history_wire\|phase61_tabs_workspace\|bundle.js\|phase60_live_clock' || true
echo

echo "== open cache-busted dashboard for mandatory UI verification =="
open "${BASE_URL}/dashboard?workspace_interactivity_guard=${STAMP}"
echo

printf '%s\n' \
'MANDATORY MANUAL UI CHECKS' \
'1. Hard refresh with Cmd+Shift+R' \
'2. Verify dashboard finishes loading' \
'3. Verify tabs are clickable' \
'4. Verify only one intended panel is visible per workspace' \
'5. Click Task Events and verify it remains interactive' \
'6. Confirm no replay storm is occurring' \
'' \
'Console checks:' \
'document.readyState' \
'document.querySelectorAll("[data-tab], [data-target], button[aria-controls]").length' \
'Array.from(document.querySelectorAll("#observational-panels > [data-workspace-panel]")).map(el => ({id: el.id, hidden: el.hidden, display: getComputedStyle(el).display}))' \
'Array.from(document.querySelectorAll("#operator-panels > [data-workspace-panel]")).map(el => ({id: el.id, hidden: el.hidden, display: getComputedStyle(el).display}))' \
'document.querySelector("[data-tab=\"task-events\"], [data-target=\"task-events\"], button[aria-controls=\"obs-panel-events\"]")?.click()' \
'document.querySelector("[data-tab-panel=\"task-events\"], #task-events-panel, #obs-panel-events")?.outerHTML'
