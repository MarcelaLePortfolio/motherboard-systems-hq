#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase472_1_external_css_neutralized.bak"
OUT="docs/phase472_1_external_css_neutralization.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

html_path = Path("public/dashboard.html")
text = html_path.read_text()

pattern = re.compile(r'^[ \t]*<link[^>]*rel="stylesheet"[^>]*>[ \t]*\n?', re.MULTILINE)

count = 0
def repl(match):
    global count
    count += 1
    line = match.group(0).strip()
    return f'<!-- phase472.1 temporary neutralization: stylesheet removed for bare-html freeze isolation :: {line} -->\n'

new_text = pattern.sub(repl, text)
if new_text == text:
    raise SystemExit("No stylesheet links were removed")

html_path.write_text(new_text)
PY

{
  echo "PHASE 472.1 — NEUTRALIZE EXTERNAL CSS AND VERIFY BARE HTML"
  echo "=========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm stylesheet links removed"
  rg -n 'phase472\.1 temporary neutralization|<link[^>]*rel="stylesheet"' "$HTML" || true
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

  echo "STEP 5 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 6 — Classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif rg -q '<link[^>]*rel="stylesheet"' "$HTML"; then
    echo "CLASSIFICATION: STYLESHEET_LINKS_STILL_PRESENT"
  elif echo "$LOGS" | rg -q 'ERROR|Error|Unhandled|exception|Cannot GET|not found'; then
    echo "CLASSIFICATION: SERVER_RUNTIME_ERROR"
  else
    echo "CLASSIFICATION: BARE_HTML_READY_FOR_BROWSER_FREEZE_ISOLATION"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report exactly one of: BARE_HTML_STABLE / BARE_HTML_STILL_UNRESPONSIVE / WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
