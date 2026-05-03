#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/69_apply_ops_renderer_fix_and_verify.txt"
mkdir -p "$(dirname "$OUT")"

docker compose up -d --build
sleep 6

TMP_HTML="$(mktemp)"
TMP_JS="$(mktemp)"
cleanup() {
  rm -f "$TMP_HTML" "$TMP_JS"
}
trap cleanup EXIT

curl -fsSL "http://localhost:8080/dashboard.html" -o "$TMP_HTML"
curl -fsSL "http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js" -o "$TMP_JS"

{
  echo "PHASE 457T — APPLY OPS RENDERER FIX AND VERIFY"
  echo "=============================================="
  echo
  echo "HTML_URL=http://localhost:8080/dashboard.html"
  echo "JS_URL=http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js"
  echo

  echo "===== LIVE HTML GUIDANCE TARGETS ====="
  grep -n 'operator-guidance-panel' "$TMP_HTML" || true
  grep -n 'operator-guidance-response' "$TMP_HTML" || true
  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
  echo

  echo "===== LIVE JS GUIDANCE SENTINELS ====="
  grep -n '__PHASE457_OPS_RENDERER_OWNER__' "$TMP_JS" || true
  grep -n 'parseGuidanceFields' "$TMP_JS" || true
  grep -n 'renderStructuredGuidance' "$TMP_JS" || true
  grep -n 'normalizeOperatorGuidance' "$TMP_JS" || true
  grep -n 'MutationObserver' "$TMP_JS" || true
  grep -n 'Confidence:\s\*unknown' "$TMP_JS" || true
  echo

  echo "===== QUICK RESULT ====="
  owner=0
  parser=0
  renderer=0
  normalizer=0
  observer=0

  grep -q '__PHASE457_OPS_RENDERER_OWNER__' "$TMP_JS" && owner=1 || true
  grep -q 'parseGuidanceFields' "$TMP_JS" && parser=1 || true
  grep -q 'renderStructuredGuidance' "$TMP_JS" && renderer=1 || true
  grep -q 'normalizeOperatorGuidance' "$TMP_JS" && normalizer=1 || true
  grep -q 'MutationObserver' "$TMP_JS" && observer=1 || true

  echo "OPS_RENDERER_OWNER=$owner"
  echo "GUIDANCE_PARSER=$parser"
  echo "STRUCTURED_RENDERER=$renderer"
  echo "GUIDANCE_NORMALIZER=$normalizer"
  echo "GUIDANCE_OBSERVER=$observer"
  echo
  echo "BROWSER_TARGET=http://localhost:8080/dashboard.html"
  echo "HARD_REFRESH=CMD+SHIFT+R"
  echo "EXPECTED=operator guidance should remain in structured multiline form without alternating"
} > "$OUT"

sed -n '1,220p' "$OUT"
