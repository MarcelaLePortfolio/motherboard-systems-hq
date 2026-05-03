#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/recovery_full_audit/60_probe_runtime_neutralizer_state.txt"
URL="http://localhost:8080/dashboard.html"
JS_URL="http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"

TMP_HTML="$(mktemp)"
TMP_JS="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML" "$TMP_JS"
}
trap cleanup EXIT

curl -fsSL "$URL" -o "$TMP_HTML"
curl -fsSL "$JS_URL" -o "$TMP_JS"

{
  echo "PHASE 457I RUNTIME NEUTRALIZER PROBE"
  echo "===================================="
  echo
  echo "HTML_URL=$URL"
  echo "JS_URL=$JS_URL"
  echo
  echo "===== LIVE HTML SCRIPT TAGS ====="
  grep -n 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" || echo "SCRIPT TAG NOT FOUND"
  echo
  echo "===== LIVE JS SENTINELS ====="
  grep -n '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_JS" || true
  grep -n 'data-phase457-neutralized' "$TMP_JS" || true
  grep -n 'Confidence: high confidence' "$TMP_JS" || true
  grep -n 'Task events stream reconnecting' "$TMP_JS" || true
  echo
  echo "===== QUICK RESULT ====="
  html_tag=0
  js_guard=0
  js_attr=0
  js_conf=0
  grep -q 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" && html_tag=1 || true
  grep -q '__PHASE457_NEUTRALIZER_ACTIVE__' "$TMP_JS" && js_guard=1 || true
  grep -q 'data-phase457-neutralized' "$TMP_JS" && js_attr=1 || true
  grep -q 'Confidence: high confidence' "$TMP_JS" && js_conf=1 || true
  echo "HTML_TAG=$html_tag"
  echo "JS_GUARD=$js_guard"
  echo "JS_ATTR=$js_attr"
  echo "JS_CONFIDENCE_PATCH=$js_conf"
} > "$OUT"

sed -n '1,220p' "$OUT"
