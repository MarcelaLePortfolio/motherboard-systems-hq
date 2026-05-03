#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
CSS_SOURCE="public/dashboard.html.phase477_8_pre_restore.bak"
BACKUP="public/dashboard.html.phase478_4_pre_dashboard_css_restore.bak"
OUT="docs/phase478_4_reintroduce_single_stylesheet_dashboard_css.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re
import sys

target_path = Path("public/dashboard.html")
source_path = Path("public/dashboard.html.phase477_8_pre_restore.bak")

target = target_path.read_text()
source = source_path.read_text()

patterns = [
    r'(?im)^\s*<link[^>]*href=["\']css/dashboard\.css(?:\?v=darkmode)?["\'][^>]*>\s*$',
    r'(?im)^\s*<link[^>]*href=["\']/?css/dashboard\.css(?:\?v=darkmode)?["\'][^>]*>\s*$',
]

match = None
for pattern in patterns:
    match = re.search(pattern, source)
    if match:
        break

if not match:
    print("ERROR: dashboard.css stylesheet tag not found in source backup", file=sys.stderr)
    sys.exit(1)

link_tag = match.group(0).strip()

if re.search(r'css/dashboard\.css(?:\?v=darkmode)?', target):
    print("DASHBOARD_CSS_ALREADY_PRESENT=1")
else:
    head_close = re.search(r'(?i)</head>', target)
    if not head_close:
        print("ERROR: could not find </head> insertion point", file=sys.stderr)
        sys.exit(1)

    insert_block = "\n" + link_tag + "\n"
    target = target[:head_close.start()] + insert_block + target[head_close.start():]
    target_path.write_text(target)

    print("DASHBOARD_CSS_REINTRODUCED=1")
    print(f"RESTORED_TAG={link_tag}")
    print(f"NEW_LEN={len(target)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 478.4 — REINTRODUCE SINGLE STYLESHEET (dashboard.css)"
  echo "==========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Backup created"
  echo "$BACKUP"
  echo
  echo "STEP 2 — Confirm active stylesheet lines"
  rg -n 'tailwind\.min\.css|dashboard\.css' "$TARGET" || true
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
  echo "STEP 6 — Probe dashboard route"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo
  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: SINGLE_STYLESHEET_DASHBOARD_CSS_REINTRODUCED"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • DASHBOARD_CSS_STABLE"
  echo "  • DASHBOARD_CSS_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
