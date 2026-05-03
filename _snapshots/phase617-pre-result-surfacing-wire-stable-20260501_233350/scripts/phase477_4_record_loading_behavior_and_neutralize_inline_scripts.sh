#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase477_4_pre_inline_script_neutralization.bak"
RESULT_OUT="docs/phase477_4_banner_removal_result.txt"
OUT="docs/phase477_4_inline_script_neutralization.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

cat > "$RESULT_OUT" <<'EOT'
PHASE 477.4 — BANNER REMOVAL RESULT
===================================

RESULT:
BANNER_REMOVAL_BREAKS

OPTIONAL_NOTE:
This version of the dashboard is still not completely right and is loading continuously.
EOT

python3 <<'PY'
from pathlib import Path
import re

target = Path("public/dashboard.html")
text = target.read_text()

pattern = re.compile(r'(?is)<script\b(?![^>]*src=)[^>]*>.*?</script>')
matches = list(pattern.finditer(text))
count = len(matches)

text = pattern.sub(lambda m: f'<!-- phase477.4 temporary neutralization: inline script block removed for structure-only isolation -->', text)
target.write_text(text)

print(f"INLINE_SCRIPT_BLOCKS_NEUTRALIZED={count}")
print(f"NEW_FILE_LEN={len(text)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 477.4 — RECORD LOADING BEHAVIOR AND NEUTRALIZE INLINE SCRIPTS"
  echo "=================================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Recorded prior result"
  sed -n '1,120p' "$RESULT_OUT"
  echo
  echo "STEP 2 — Backup"
  echo "$BACKUP"
  echo
  echo "STEP 3 — Confirm remaining script tags"
  rg -n '<script' "$TARGET" || true
  echo
  echo "STEP 4 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo
  echo "STEP 5 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo
  echo "STEP 6 — Wait for host port 8080 readiness"
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
  echo "STEP 7 — Probe dashboard route"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "STEP 8 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo
  echo "STEP 9 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: INLINE_SCRIPTS_NEUTRALIZED_READY"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • INLINE_SCRIPT_FREE_STABLE"
  echo "  • INLINE_SCRIPT_FREE_STILL_LOADING"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
