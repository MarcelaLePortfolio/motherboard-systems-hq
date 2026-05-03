#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
TOP_PROBE="public/dashboard_body_top_half_probe.html"
BOTTOM_PROBE="public/dashboard_body_bottom_half_probe.html"
OUT="docs/phase475_3_create_dashboard_half_probes_and_verify.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public

python3 - <<'PY'
from pathlib import Path
import re

src = Path("public/dashboard.html").read_text()

head_match = re.search(r'(<head\b[^>]*>.*?</head>)', src, re.IGNORECASE | re.DOTALL)
body_match = re.search(r'<body\b[^>]*>(.*?)</body>', src, re.IGNORECASE | re.DOTALL)

if not head_match or not body_match:
    raise SystemExit("Could not extract <head> or <body> from public/dashboard.html")

head = head_match.group(1)
body_inner = body_match.group(1)

lines = body_inner.splitlines()
if not lines:
    raise SystemExit("Dashboard body is empty; cannot split into halves")

mid = max(1, len(lines) // 2)
top_lines = "\n".join(lines[:mid]).strip()
bottom_lines = "\n".join(lines[mid:]).strip()

top_html = f"""<!DOCTYPE html>
<html lang="en">
{head}
<body>
<!-- phase475.3 top half dashboard body probe -->
<div style="padding: 12px; font-family: sans-serif;">
  <p><strong>Phase 475.3:</strong> top half dashboard body probe</p>
</div>
{top_lines}
</body>
</html>
"""

bottom_html = f"""<!DOCTYPE html>
<html lang="en">
{head}
<body>
<!-- phase475.3 bottom half dashboard body probe -->
<div style="padding: 12px; font-family: sans-serif;">
  <p><strong>Phase 475.3:</strong> bottom half dashboard body probe</p>
</div>
{bottom_lines}
</body>
</html>
"""

Path("public/dashboard_body_top_half_probe.html").write_text(top_html)
Path("public/dashboard_body_bottom_half_probe.html").write_text(bottom_html)

print(f"BODY_LINE_COUNT={len(lines)}")
print(f"TOP_HALF_LINE_COUNT={len(lines[:mid])}")
print(f"BOTTOM_HALF_LINE_COUNT={len(lines[mid:])}")
PY

{
  echo "PHASE 475.3 — CREATE DASHBOARD HALF PROBES AND VERIFY"
  echo "====================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm probes were created"
  wc -l "$TOP_PROBE" || true
  wc -l "$BOTTOM_PROBE" || true
  echo
  echo "--- TOP PROBE HEADER ---"
  sed -n '1,40p' "$TOP_PROBE" || true
  echo
  echo "--- BOTTOM PROBE HEADER ---"
  sed -n '1,40p' "$BOTTOM_PROBE" || true
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
    if curl -s --max-time 2 http://localhost:8080/dashboard_body_top_half_probe.html >/dev/null 2>&1; then
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

  echo "STEP 5 — Probe routes"
  echo "--- GET /dashboard_body_top_half_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_top_half_probe.html 2>&1 || true
  echo
  echo "--- GET /dashboard_body_bottom_half_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_bottom_half_probe.html 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/dashboard_body_top_half_probe.html | grep -q 'top half dashboard body probe' \
    && curl -s --max-time 5 http://localhost:8080/dashboard_body_bottom_half_probe.html | grep -q 'bottom half dashboard body probe'; then
    echo "CLASSIFICATION: DASHBOARD_HALF_PROBES_READY"
  else
    echo "CLASSIFICATION: DASHBOARD_HALF_PROBES_NOT_SERVED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard_body_top_half_probe.html first"
  echo "- Report EXACTLY one of:"
  echo "  • TOP_HALF_PROBE_STABLE"
  echo "  • TOP_HALF_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
