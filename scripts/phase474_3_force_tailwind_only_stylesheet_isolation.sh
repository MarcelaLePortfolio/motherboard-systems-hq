#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase474_3_pre_force_tailwind_only.bak"
OUT="docs/phase474_3_force_tailwind_only_stylesheet_isolation.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public
cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text()

def replace_link(match):
    tag = match.group(0)
    href_match = re.search(r'href="([^"]+)"', tag)
    href = href_match.group(1) if href_match else ""
    if "cdn.jsdelivr.net/npm/tailwindcss" in href:
        return tag
    return f'<!-- phase474.3 temporary neutralization: removed local stylesheet :: {tag} -->'

pattern = re.compile(r'<link\b[^>]*rel="stylesheet"[^>]*>', re.IGNORECASE)
text, count = pattern.subn(replace_link, text)

p.write_text(text)
print(f"FORCED_TAILWIND_ONLY_COUNT={count}")
PY

{
  echo "PHASE 474.3 — FORCE TRUE TAILWIND-ONLY STYLESHEET ISOLATION"
  echo "==========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Active stylesheet links (should ONLY show Tailwind)"
  rg -n '<link[^>]*rel="stylesheet"' "$HTML" || true
  echo

  echo "STEP 2 — Confirm bundle still disabled"
  rg -n 'bundle\.js removed' "$HTML" || true
  echo

  echo "STEP 3 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo

  echo "STEP 4 — Recreate container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo

  echo "STEP 5 — Wait for 8080"
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

  echo "STEP 6 — Probe"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 7 — Logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: TRUE_TAILWIND_ONLY_READY"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY:"
  echo "  • TRUE_TAILWIND_ONLY_STABLE"
  echo "  • TRUE_TAILWIND_ONLY_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"
