#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase478_1_pre_script_restore.bak"
OUT="docs/phase478_1_reintroduce_phase60_live_clock.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re

target_path = Path("public/dashboard.html")
backup_path = Path("public/dashboard.html.phase476_6_pre_strip.bak")

target = target_path.read_text()
backup = backup_path.read_text()

# Extract ONLY the phase60_live_clock script tag from backup
match = re.search(r'(?im)<script[^>]*phase60_live_clock\.js[^>]*></script>', backup)

if not match:
    print("ERROR: phase60_live_clock.js not found in backup")
    exit(1)

script_tag = match.group(0)

# Insert script before closing </body>
if "</body>" in target:
    target = target.replace("</body>", f"  {script_tag}\n</body>")
else:
    print("ERROR: </body> not found")
    exit(1)

target_path.write_text(target)

print("SCRIPT_REINTRODUCED=phase60_live_clock.js")
print(f"NEW_LEN={len(target)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 478.1 — REINTRODUCE SINGLE SCRIPT (phase60_live_clock.js)"
  echo "================================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Backup created"
  echo "$BACKUP"
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
    echo "CLASSIFICATION: SINGLE_SCRIPT_PHASE60_REINTRODUCED"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • PHASE60_SCRIPT_STABLE"
  echo "  • PHASE60_SCRIPT_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
