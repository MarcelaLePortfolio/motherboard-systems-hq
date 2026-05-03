#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
SCRIPT_TAG='    <script src="/js/phase457_neutralize_legacy_observational_consumers.js"></script>'
OUT="docs/recovery_full_audit/59_neutralize_legacy_observational_consumers.txt"

python3 - <<'PY'
from pathlib import Path

target = Path("public/dashboard.html")
needle = '    <script src="/js/phase457_restore_task_panels.js"></script>'
insert = '    <script src="/js/phase457_neutralize_legacy_observational_consumers.js"></script>'

text = target.read_text()

if insert not in text:
    if needle in text:
        text = text.replace(needle, needle + "\n" + insert, 1)
    else:
        text = text.rstrip() + "\n" + insert + "\n"

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
  echo "PHASE 457H LEGACY OBSERVATIONAL CONSUMER NEUTRALIZATION"
  echo "======================================================"
  echo
  echo "TARGET=$TARGET"
  echo "LIVE_URL=http://localhost:8080/dashboard.html"
  echo
  echo "===== LOCAL SCRIPT TAG CHECK ====="
  grep -n 'phase457_neutralize_legacy_observational_consumers.js' "$TARGET" || echo "LOCAL TAG NOT FOUND"
  echo
  echo "===== LIVE SCRIPT TAG CHECK ====="
  grep -n 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" || echo "LIVE TAG NOT FOUND"
  echo
  echo "===== LIVE PANEL IDS ====="
  grep -n 'tasks-widget' "$TMP_HTML" || true
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'mb-task-events-panel-anchor' "$TMP_HTML" || true
  grep -n 'operator-guidance-response' "$TMP_HTML" || true
  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
  echo
  echo "===== LOCAL NEUTRALIZER CHECK ====="
  grep -n 'normalizeOperatorConfidence' public/js/phase457_neutralize_legacy_observational_consumers.js || true
  grep -n 'neutralizeLegacyProbeText' public/js/phase457_neutralize_legacy_observational_consumers.js || true
  grep -n 'connectDirectTaskEvents' public/js/phase457_neutralize_legacy_observational_consumers.js || true
  echo
  echo "===== QUICK RESULT ====="
  local_tag=0
  live_tag=0
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TARGET" && local_tag=1 || true
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" && live_tag=1 || true
  echo "LOCAL_TAG=$local_tag"
  echo "LIVE_TAG=$live_tag"
} > "$OUT"

sed -n '1,220p' "$OUT"
