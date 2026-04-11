#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase476_6_pre_strip.bak"
OUT="docs/phase477_8_restore_structural_layout_from_backup.txt"

mkdir -p docs

cp "$TARGET" "${TARGET}.phase477_8_pre_restore.bak"

python3 <<'PY'
from pathlib import Path
import re

target_path = Path("public/dashboard.html")
backup_path = Path("public/dashboard.html.phase476_6_pre_strip.bak")

target = target_path.read_text()
backup = backup_path.read_text()

def strip_scripts(text):
    text = re.sub(r'(?is)<script.*?>.*?</script>', '', text)
    text = re.sub(r'(?im)^[ \t]*<script[^>]*src=["\'][^"\']+["\'][^>]*></script>[ \t]*\n?', '', text)
    return text

def extract_body(text):
    m = re.search(r'(?is)<body[^>]*>(.*)</body>', text)
    return m.group(1) if m else ""

backup_body = extract_body(strip_scripts(backup))
target_body = extract_body(target)

# Preserve current stable head + body tag, replace ONLY inner structure
new_html = re.sub(
    r'(?is)(<body[^>]*>)(.*?)(</body>)',
    lambda m: m.group(1) + "\n" + backup_body.strip() + "\n" + m.group(3),
    target
)

target_path.write_text(new_html)

print("STRUCTURAL_BODY_RESTORED_FROM_BACKUP")
print(f"NEW_LEN={len(new_html)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 477.8 — RESTORE STRUCTURAL LAYOUT FROM BACKUP (NO SCRIPTS)"
  echo "================================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Backup created"
  echo "${TARGET}.phase477_8_pre_restore.bak"
  echo
  echo "STEP 2 — Rebuild dashboard image"
  docker compose build dashboard 2>&1 || true
  echo
  echo "STEP 3 — Recreate dashboard container"
  docker compose up -d --force-recreate dashboard 2>&1 || true
  echo
  echo "STEP 4 — Wait for host port 8080 readiness"
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
  echo "STEP 5 — Probe dashboard route"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo
  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: STRUCTURAL_LAYOUT_RESTORED_NO_SCRIPTS"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • STRUCTURE_RESTORED_CORRECT"
  echo "  • STRUCTURE_RESTORED_BUT_BROKEN"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
