#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase474_4_true_tailwind_only_result.txt"
HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase474_4_pre_inline_style_neutralization.bak"
OUT="docs/phase474_4_inline_style_neutralization.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public
cp "$HTML" "$BACKUP"

cat > "$RESULT_OUT" <<'EOT'
PHASE 474.4 — TRUE TAILWIND ONLY RESULT
=======================================

RESULT:
TRUE_TAILWIND_ONLY_STILL_UNRESPONSIVE

OPTIONAL_NOTE:
Tailwind-only shell still becomes unresponsive.
EOT

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text()

# Neutralize all inline <style> blocks while leaving the rest of the HTML intact.
pattern = re.compile(r'<style\b[^>]*>.*?</style>', re.IGNORECASE | re.DOTALL)
text, count = pattern.subn(
    lambda m: f'<!-- phase474.4 temporary neutralization: inline style block removed for HTML-only layout isolation -->',
    text
)

p.write_text(text)
print(f"INLINE_STYLE_BLOCKS_NEUTRALIZED={count}")
PY

{
  echo "PHASE 474.4 — CAPTURE TRUE TAILWIND-ONLY RESULT AND NEUTRALIZE INLINE STYLES"
  echo "============================================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Recorded true tailwind-only result"
  sed -n '1,120p' "$RESULT_OUT"
  echo

  echo "STEP 2 — Confirm remaining stylesheet links"
  rg -n '^[[:space:]]*<link[^>]*rel="stylesheet"' "$HTML" || true
  echo

  echo "STEP 3 — Confirm inline style blocks are now gone"
  rg -n '<style\b' "$HTML" || true
  echo

  echo "STEP 4 — Confirm bundle still disabled"
  rg -n 'bundle\.js removed' "$HTML" || true
  echo

  echo "STEP 5 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo

  echo "STEP 6 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo

  echo "STEP 7 — Wait for host port 8080 readiness"
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

  echo "STEP 8 — Probe dashboard"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 9 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 10 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: INLINE_STYLES_REMOVED_BUNDLE_STILL_OFF"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY:"
  echo "  • INLINE_STYLE_FREE_SHELL_STABLE"
  echo "  • INLINE_STYLE_FREE_SHELL_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
