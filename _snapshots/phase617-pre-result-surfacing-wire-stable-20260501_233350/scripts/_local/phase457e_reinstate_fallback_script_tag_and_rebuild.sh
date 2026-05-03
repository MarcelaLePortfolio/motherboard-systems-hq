#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/56_reinstate_fallback_script_tag_and_rebuild.txt"
TARGET="public/dashboard.html"
SCRIPT_TAG='    <script src="/js/phase457_restore_task_panels.js"></script>'

python3 - <<'PY'
from pathlib import Path

target = Path("public/dashboard.html")
text = target.read_text()

script_tag = '    <script src="/js/phase457_restore_task_panels.js"></script>'

if script_tag not in text:
    if "</body>" in text:
        text = text.replace("</body>", f"{script_tag}\n</body>", 1)
    else:
        text = text.rstrip() + "\n" + script_tag + "\n"
    target.write_text(text)
PY

docker compose up -d --build

sleep 6

TMP_HTML="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML"
}
trap cleanup EXIT

curl -fsSL "http://localhost:8080/dashboard.html" -o "$TMP_HTML"

{
  echo "PHASE 457E FALLBACK SCRIPT TAG REINSTATEMENT"
  echo "============================================"
  echo
  echo "TARGET=$TARGET"
  echo "LIVE_URL=http://localhost:8080/dashboard.html"
  echo
  echo "===== LOCAL SCRIPT TAG CHECK ====="
  grep -n 'phase457_restore_task_panels.js' "$TARGET" || echo "LOCAL SCRIPT TAG NOT FOUND"
  echo
  echo "===== LIVE SCRIPT TAG CHECK ====="
  grep -n 'phase457_restore_task_panels.js' "$TMP_HTML" || echo "LIVE SCRIPT TAG NOT FOUND"
  echo
  echo "===== PANEL IDS ====="
  grep -n 'tasks-widget' "$TMP_HTML" || true
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'mb-task-events-panel-anchor' "$TMP_HTML" || true
  grep -n 'operator-guidance' "$TMP_HTML" || true
  echo
  echo "===== QUICK RESULT ====="
  local_tag=0
  live_tag=0
  grep -q 'phase457_restore_task_panels.js' "$TARGET" && local_tag=1 || true
  grep -q 'phase457_restore_task_panels.js' "$TMP_HTML" && live_tag=1 || true
  echo "LOCAL_TAG=$local_tag"
  echo "LIVE_TAG=$live_tag"
} > "$OUT"

sed -n '1,200p' "$OUT"
