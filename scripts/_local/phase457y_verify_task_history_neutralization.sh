#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/72_verify_task_history_neutralization.txt"
mkdir -p "$(dirname "$OUT")"

TMP_HTML="$(mktemp)"
TMP_JS="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML" "$TMP_JS"
}
trap cleanup EXIT

curl -fsSL "http://localhost:8080/dashboard.html" -o "$TMP_HTML"
curl -fsSL "http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js" -o "$TMP_JS"

{
  echo "PHASE 457Y — TASK HISTORY NEUTRALIZATION VERIFICATION"
  echo "====================================================="
  echo
  echo "HTML_URL=http://localhost:8080/dashboard.html"
  echo "JS_URL=http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"
  echo
  echo "===== LIVE HTML TARGETS ====="
  grep -n 'recentLogs' "$TMP_HTML" || true
  grep -n 'tasks-widget' "$TMP_HTML" || true
  echo
  echo "===== LIVE JS SENTINELS ====="
  grep -n 'Error loading Task Activity' "$TMP_JS" || true
  grep -n 'relation "run_view" does not exist' "$TMP_JS" || true
  grep -n 'No task history yet.' "$TMP_JS" || true
  grep -n 'normalizeLegacyStatusPanels' "$TMP_JS" || true
  echo
  echo "===== QUICK RESULT ====="
  HISTORY_ERROR_MATCH=0
  HISTORY_EMPTY_MATCH=0
  NORMALIZER_PRESENT=0

  grep -q 'Error loading Task Activity' "$TMP_JS" && HISTORY_ERROR_MATCH=1 || true
  grep -q 'No task history yet.' "$TMP_JS" && HISTORY_EMPTY_MATCH=1 || true
  grep -q 'normalizeLegacyStatusPanels' "$TMP_JS" && NORMALIZER_PRESENT=1 || true

  echo "HISTORY_ERROR_MATCH=$HISTORY_ERROR_MATCH"
  echo "HISTORY_EMPTY_MATCH=$HISTORY_EMPTY_MATCH"
  echo "NORMALIZER_PRESENT=$NORMALIZER_PRESENT"
  echo
  echo "BROWSER_TARGET=http://localhost:8080/dashboard.html"
  echo "HARD_REFRESH=CMD+SHIFT+R"
  echo "EXPECTED=task history should show 'No task history yet.' instead of run_view error text"
} > "$OUT"

sed -n '1,240p' "$OUT"
