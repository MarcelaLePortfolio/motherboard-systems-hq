#!/usr/bin/env bash
set -euo pipefail

OUT="docs/recovery_full_audit/71_verify_post_interactivity_recovery.txt"
mkdir -p "$(dirname "$OUT")"

TMP_HTML="$(mktemp)"
TMP_JS_NEUTRAL="$(mktemp)"
TMP_JS_GUIDE="$(mktemp)"
TMP_TASKS="$(mktemp)"
TMP_OPS="$(mktemp)"

cleanup() {
  rm -f "$TMP_HTML" "$TMP_JS_NEUTRAL" "$TMP_JS_GUIDE" "$TMP_TASKS" "$TMP_OPS"
}
trap cleanup EXIT

curl -fsSL "http://localhost:8080/dashboard.html" -o "$TMP_HTML"
curl -fsSL "http://localhost:8080/js/phase457_neutralize_legacy_observational_consumers.js" -o "$TMP_JS_NEUTRAL"
curl -fsSL "http://localhost:8080/js/operatorGuidance.sse.js" -o "$TMP_JS_GUIDE"
curl -fsSL "http://localhost:8080/api/tasks?limit=20" -o "$TMP_TASKS"
python3 - <<'PY' > "$TMP_OPS"
import sys, urllib.request
req = urllib.request.Request("http://localhost:8080/events/ops", headers={"Accept": "text/event-stream"})
with urllib.request.urlopen(req, timeout=5) as r:
    data = r.read(5120)
sys.stdout.buffer.write(data)
PY

{
  echo "PHASE 457X — POST INTERACTIVITY RECOVERY VERIFICATION"
  echo "====================================================="
  echo
  echo "HTML_URL=http://localhost:8080/dashboard.html"
  echo "TASKS_URL=http://localhost:8080/api/tasks?limit=20"
  echo "OPS_URL=http://localhost:8080/events/ops"
  echo

  echo "===== LIVE HTML TARGETS ====="
  grep -n 'operator-guidance-panel' "$TMP_HTML" || true
  grep -n 'operator-guidance-response' "$TMP_HTML" || true
  grep -n 'operator-guidance-meta' "$TMP_HTML" || true
  grep -n 'phase457_neutralize_legacy_observational_consumers.js' "$TMP_HTML" || true
  echo

  echo "===== PHASE457 JS SENTINELS ====="
  grep -n '__PHASE457_OPS_RENDERER_OWNER__' "$TMP_JS_NEUTRAL" || true
  grep -n 'requestAnimationFrame(runNormalizationPass)' "$TMP_JS_NEUTRAL" || true
  grep -n 'MutationObserver' "$TMP_JS_NEUTRAL" || true
  grep -n 'setInterval' "$TMP_JS_NEUTRAL" || true
  echo

  echo "===== LEGACY GUIDANCE WRITER STATUS ====="
  sed -n '1,120p' "$TMP_JS_GUIDE"
  echo

  echo "===== TASKS SNAPSHOT ====="
  cat "$TMP_TASKS"
  echo
  echo

  echo "===== OPS SNAPSHOT ====="
  sed -n '1,20p' "$TMP_OPS" || true
  echo

  echo "===== QUICK RESULT ====="
  PHASE457_OWNER=0
  RAF_SCHEDULE=0
  OBSERVER_PRESENT=0
  LOOP_PRESENT=0
  LEGACY_NEUTRALIZED=0
  TASKS_OK=0
  OPS_STREAM_OK=0

  grep -q '__PHASE457_OPS_RENDERER_OWNER__' "$TMP_JS_NEUTRAL" && PHASE457_OWNER=1 || true
  grep -q 'requestAnimationFrame(runNormalizationPass)' "$TMP_JS_NEUTRAL" && RAF_SCHEDULE=1 || true
  grep -q 'MutationObserver' "$TMP_JS_NEUTRAL" && OBSERVER_PRESENT=1 || true
  grep -q 'setInterval' "$TMP_JS_NEUTRAL" && LOOP_PRESENT=1 || true
  grep -q '__OPERATOR_GUIDANCE_SSE_NEUTRALIZED__' "$TMP_JS_GUIDE" && LEGACY_NEUTRALIZED=1 || true
  grep -q '"ok":true' "$TMP_TASKS" && TASKS_OK=1 || true
  grep -q 'event: ops.state' "$TMP_OPS" && OPS_STREAM_OK=1 || true

  echo "PHASE457_OWNER=$PHASE457_OWNER"
  echo "RAF_SCHEDULE=$RAF_SCHEDULE"
  echo "OBSERVER_PRESENT=$OBSERVER_PRESENT"
  echo "LOOP_PRESENT=$LOOP_PRESENT"
  echo "LEGACY_NEUTRALIZED=$LEGACY_NEUTRALIZED"
  echo "TASKS_OK=$TASKS_OK"
  echo "OPS_STREAM_OK=$OPS_STREAM_OK"
  echo
  echo "BROWSER_TARGET=http://localhost:8080/dashboard.html"
  echo "MANUAL_CHECK_1=tabs and buttons should remain clickable"
  echo "MANUAL_CHECK_2=operator guidance should stay structured"
  echo "MANUAL_CHECK_3=dashboard should not freeze after load"
} > "$OUT"

sed -n '1,260p' "$OUT"
