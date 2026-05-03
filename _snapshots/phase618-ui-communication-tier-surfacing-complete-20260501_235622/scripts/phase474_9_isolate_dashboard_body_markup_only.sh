#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase474_9_pre_body_isolation.bak"
OUT="docs/phase474_9_isolate_dashboard_body_markup_only.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public
cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text()

body_re = re.compile(r'(<body\b[^>]*>)(.*?)(</body>)', re.IGNORECASE | re.DOTALL)
replacement = r"""\1
  <main style="padding: 24px; font-family: sans-serif;">
    <h1>Dashboard Body Isolation Probe</h1>
    <p>If this page stays responsive, the freeze is caused by dashboard body markup structure rather than server delivery, scripts, or styles.</p>
    <p>Phase 474.9 keeps the same route and file, but replaces only the body contents.</p>
  </main>
\3"""

new_text, count = body_re.subn(replacement, text, count=1)
if count != 1:
    raise SystemExit("Failed to replace <body> contents exactly once")

p.write_text(new_text)
print(f"BODY_CONTENT_REPLACED={count}")
PY

{
  echo "PHASE 474.9 — ISOLATE DASHBOARD BODY MARKUP ONLY"
  echo "==============================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm bundle remains disabled"
  rg -n 'bundle\.js removed' "$HTML" || true
  echo

  echo "STEP 2 — Confirm body isolation text is present"
  rg -n 'Dashboard Body Isolation Probe|Phase 474.9 keeps the same route' "$HTML" || true
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
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: BODY_MARKUP_ISOLATION_READY"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY:"
  echo "  • BODY_ISOLATION_STABLE"
  echo "  • BODY_ISOLATION_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
