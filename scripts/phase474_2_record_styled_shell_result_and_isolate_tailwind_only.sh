#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT_OUT="docs/phase474_1_styled_shell_result.txt"
HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase474_2_pre_tailwind_only_restore.bak"
OUT="docs/phase474_2_tailwind_only_isolation.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public
cp "$HTML" "$BACKUP"

cat > "$RESULT_OUT" <<'EOT'
PHASE 474.1 — STYLED SHELL RESULT
=================================

RESULT:
STYLED_SHELL_STILL_UNRESPONSIVE

OPTIONAL_NOTE:
UI restored, but page becomes unresponsive again.
EOT

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
text = p.read_text()

# Keep only Tailwind active; neutralize local/custom stylesheet links.
def repl(m):
    tag = m.group(0)
    href = m.group(1)
    if "cdn.jsdelivr.net/npm/tailwindcss" in href:
        return tag
    return f'<!-- phase474.2 temporary neutralization: local stylesheet removed for tailwind-only isolation :: {tag} -->'

pattern = re.compile(r'<link[^>]*href="([^"]+)"[^>]*rel="stylesheet"[^>]*>')
text, count = pattern.subn(repl, text)

p.write_text(text)
print(f"TAILWIND_ONLY_LINK_PASS_COUNT={count}")
PY

{
  echo "PHASE 474.2 — RECORD STYLED SHELL RESULT AND ISOLATE TAILWIND ONLY"
  echo "=================================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Recorded styled-shell result"
  sed -n '1,120p' "$RESULT_OUT"
  echo

  echo "STEP 2 — Active stylesheet links after tailwind-only isolation"
  rg -n '^[[:space:]]*<link[^>]*rel="stylesheet"' "$HTML" || true
  echo

  echo "STEP 3 — Confirm bundle remains disabled"
  rg -n 'phase471\.4 temporary neutralization: bundle\.js removed' "$HTML" || true
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

  echo "STEP 7 — Probe dashboard"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 8 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 9 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: TAILWIND_ONLY_SHELL_READY"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report exactly one of:"
  echo "  • TAILWIND_ONLY_STABLE"
  echo "  • TAILWIND_ONLY_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
