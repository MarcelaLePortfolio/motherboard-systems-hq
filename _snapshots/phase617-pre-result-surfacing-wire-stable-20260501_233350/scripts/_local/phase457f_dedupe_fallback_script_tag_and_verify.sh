#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/recovery_full_audit/57_dedupe_fallback_script_tag_and_verify.txt"
TARGET="public/dashboard.html"
TAG='<script src="/js/phase457_restore_task_panels.js"></script>'

python3 - <<'PY'
from pathlib import Path

target = Path("public/dashboard.html")
text = target.read_text()

needle = '<script src="/js/phase457_restore_task_panels.js"></script>'
count = text.count(needle)

if count == 0:
    if "</body>" in text:
        text = text.replace("</body>", f"    {needle}\n</body>", 1)
    else:
        text = text.rstrip() + "\n    " + needle + "\n"
elif count > 1:
    first = text.find(needle)
    before = text[:first + len(needle)]
    after = text[first + len(needle):].replace(needle, "")
    text = before + after

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
  echo "PHASE 457F DEDUPE FALLBACK SCRIPT TAG"
  echo "===================================="
  echo
  echo "TARGET=$TARGET"
  echo "LIVE_URL=http://localhost:8080/dashboard.html"
  echo
  echo "===== LOCAL TAG COUNT ====="
  grep -n 'phase457_restore_task_panels.js' "$TARGET" || true
  echo "LOCAL_COUNT=$(grep -c 'phase457_restore_task_panels.js' "$TARGET" || true)"
  echo
  echo "===== LIVE TAG COUNT ====="
  grep -n 'phase457_restore_task_panels.js' "$TMP_HTML" || true
  echo "LIVE_COUNT=$(grep -c 'phase457_restore_task_panels.js' "$TMP_HTML" || true)"
  echo
  echo "===== PANEL IDS ====="
  grep -n 'tasks-widget' "$TMP_HTML" || true
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'mb-task-events-panel-anchor' "$TMP_HTML" || true
  grep -n 'operator-guidance' "$TMP_HTML" || true
} > "$OUT"

sed -n '1,200p' "$OUT"
