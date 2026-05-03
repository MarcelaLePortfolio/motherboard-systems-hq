#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase471_4_bundle_boot_neutralized.bak"
OUT="docs/phase471_4_bundle_boot_neutralization.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

html_path = Path("public/dashboard.html")
text = html_path.read_text()

pattern = re.compile(r'^[ \t]*<script src="bundle\.js"></script>[ \t]*\n?', re.MULTILINE)
replacement = '<!-- phase471.4 temporary neutralization: bundle.js removed to isolate browser freeze to JS boot layer -->\n'

new_text, count = pattern.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit(f"Expected to remove exactly one bundle.js script tag, removed={count}")

html_path.write_text(new_text)
PY

{
  echo "PHASE 471.4 — NEUTRALIZE BUNDLE BOOT AND VERIFY STATIC SHELL"
  echo "==========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm bundle.js script tag removed"
  echo "--- bundle marker search ---"
  rg -n 'phase471\.4 temporary neutralization|<script src="bundle\.js"></script>' "$HTML" || true
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
  elif rg -q '<script src="bundle\.js"></script>' "$HTML"; then
    echo "CLASSIFICATION: BUNDLE_SCRIPT_STILL_PRESENT"
  elif echo "$LOGS" | rg -q '\[HTTP\] GET /bundle\.js'; then
    echo "CLASSIFICATION: BUNDLE_STILL_REQUESTED_AFTER_REMOVAL"
  else
    echo "CLASSIFICATION: STATIC_SHELL_READY_FOR_BROWSER_FREEZE_ISOLATION"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report exactly one of: STATIC_SHELL_STABLE / STATIC_SHELL_STILL_UNRESPONSIVE / WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
