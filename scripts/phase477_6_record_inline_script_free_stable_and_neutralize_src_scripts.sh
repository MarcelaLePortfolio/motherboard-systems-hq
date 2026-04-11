#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase477_6_pre_src_script_neutralization.bak"
RESULT_OUT="docs/phase477_6_inline_script_free_result.txt"
OUT="docs/phase477_6_src_script_neutralization.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

cat > "$RESULT_OUT" <<'EOT'
PHASE 477.6 — INLINE-SCRIPT-FREE RESULT
=======================================

RESULT:
INLINE_SCRIPT_FREE_STABLE

OPTIONAL_NOTE:
The dashboard is stable, but still not quite right structurally.
EOT

python3 <<'PY'
from pathlib import Path
import re

target = Path("public/dashboard.html")
text = target.read_text()

pattern = re.compile(r'(?im)^[ \t]*<script\b[^>]*\bsrc=["\'][^"\']+["\'][^>]*></script>[ \t]*\n?')
matches = pattern.findall(text)
count = len(matches)

text = pattern.sub('<!-- phase477.6 temporary neutralization: src script removed for pure structure isolation -->\n', text)
text = re.sub(r'\n{3,}', '\n\n', text)

target.write_text(text)

print(f"SRC_SCRIPT_TAGS_NEUTRALIZED={count}")
print(f"NEW_FILE_LEN={len(text)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 477.6 — RECORD INLINE-SCRIPT-FREE STABLE AND NEUTRALIZE SRC SCRIPTS"
  echo "========================================================================="
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
    echo "CLASSIFICATION: PURE_STRUCTURE_DASHBOARD_READY"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • SRC_SCRIPT_FREE_STABLE"
  echo "  • SRC_SCRIPT_FREE_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
