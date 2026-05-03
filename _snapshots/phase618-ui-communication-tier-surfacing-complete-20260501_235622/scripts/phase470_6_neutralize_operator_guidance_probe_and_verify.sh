#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase470_6_operator_guidance_neutralized.bak"
OUT="docs/phase470_6_operator_guidance_neutralization.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
html_path = Path("public/dashboard.html")
text = html_path.read_text()

old = '<script src="/js/operatorGuidance.sse.js?v=phase96-live-1"></script>'
new = '<!-- phase470.6 temporary neutralization: operatorGuidance.sse.js removed to isolate dashboard freeze / unresponsive behavior -->'

if old in text:
    text = text.replace(old, new, 1)
else:
    marker = 'operatorGuidance.sse.js'
    if marker in text:
        raise SystemExit("operator guidance script marker changed; manual review required")
html_path.write_text(text)
PY

{
  echo "PHASE 470.6 — NEUTRALIZE OPERATOR GUIDANCE PROBE AND VERIFY"
  echo "==========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Confirm script tag neutralized"
  rg -n "operatorGuidance\\.sse\\.js|phase470\\.6 temporary neutralization" "$HTML" || true
  echo
  echo "STEP 2 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo
  echo "STEP 3 — Wait for host port 8080 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
      READY=1
      echo "READY_ON_8080 attempt=$i"
      break
    fi
    sleep 2
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo
  echo "STEP 4 — Fresh probes"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -I --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET /api/operator-guidance ---"
  curl -I --max-time 5 http://localhost:8080/api/operator-guidance 2>&1 || true
  echo
  echo "STEP 5 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo
  echo "STEP 6 — Classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif echo "$LOGS" | rg -q '\\[HTTP\\] GET /js/operatorGuidance\\.sse\\.js'; then
    echo "CLASSIFICATION: SCRIPT_STILL_REQUESTED"
  elif echo "$LOGS" | rg -q '\\[HTTP\\] GET /api/operator-guidance'; then
    echo "CLASSIFICATION: OPERATOR_GUIDANCE_API_STILL_HIT"
  else
    echo "CLASSIFICATION: OPERATOR_GUIDANCE_NEUTRALIZED_FOR_BROWSER_FREEZE_ISOLATION"
  fi
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
