#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase473_9_pre_styles_restore.bak"
OUT="docs/phase473_9_restore_styles_only_and_verify.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public
cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text()

pattern = re.compile(
    r'<!-- phase472\.1 temporary neutralization: stylesheet removed for bare-html freeze isolation :: (.*?) -->'
)

text, count = pattern.subn(lambda m: m.group(1), text)

p.write_text(text)
print(f"RESTORED_STYLESHEET_COUNT={count}")
PY

{
  echo "PHASE 473.9 — RESTORE STYLES ONLY AND VERIFY"
  echo "============================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm stylesheet links are active again"
  rg -n '^[[:space:]]*<link[^>]*rel="stylesheet"' "$HTML" || true
  echo

  echo "STEP 2 — Confirm bundle is still neutralized"
  rg -n 'phase471\.4 temporary neutralization: bundle\.js removed' "$HTML" || true
  echo

  echo "STEP 3 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo

  echo "STEP 4 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo

  echo "STEP 5 — Wait for host port 8080 readiness"
  READY=0
  for i in {1..20}; do
    if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
      READY=1
      echo "READY_ON_8080 attempt=$i"
      break
    fi
    sleep 1
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo

  echo "STEP 6 — Probe dashboard"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: STYLES_RESTORED_BUNDLE_STILL_OFF"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report exactly one of:"
  echo "  • STYLED_SHELL_STABLE"
  echo "  • STYLED_SHELL_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
