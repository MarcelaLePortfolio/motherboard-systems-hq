#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase475_9_create_q3_q4_probes_and_verify.txt"
SRC="public/dashboard_body_bottom_half_probe.html"
Q3="public/dashboard_body_q3_probe.html"
Q4="public/dashboard_body_q4_probe.html"

mkdir -p docs

python3 <<'PY'
from pathlib import Path
import re
import sys

src = Path("public/dashboard_body_bottom_half_probe.html")
q3 = Path("public/dashboard_body_q3_probe.html")
q4 = Path("public/dashboard_body_q4_probe.html")

text = src.read_text()

body_match = re.search(r"<body[^>]*>(.*)</body>", text, re.S | re.I)
if not body_match:
    raise SystemExit("Could not locate <body>...</body> in bottom-half probe.")

body = body_match.group(1)

marker = '<!-- phase475.3 bottom half dashboard body probe -->'
idx = body.find(marker)
if idx == -1:
    raise SystemExit("Could not locate bottom-half probe marker in body.")

body_payload = body[idx:]
lines = body_payload.splitlines()

mid = len(lines) // 2
q3_lines = lines[:mid]
q4_lines = lines[mid:]

head = text[:body_match.start(1)]
tail = text[body_match.end(1):]

q3_body = '\n'.join([
    '<div style="padding: 12px; font-family: sans-serif;">',
    '  <p><strong>Phase 475.9:</strong> Q3 dashboard body probe</p>',
    '</div>',
    *q3_lines,
])

q4_body = '\n'.join([
    '<div style="padding: 12px; font-family: sans-serif;">',
    '  <p><strong>Phase 475.9:</strong> Q4 dashboard body probe</p>',
    '</div>',
    *q4_lines,
])

q3.write_text(head + q3_body + tail)
q4.write_text(head + q4_body + tail)

print(f"BOTTOM_HALF_CONTENT_LINE_COUNT={len(lines)}")
print(f"Q3_LINE_COUNT={len(q3_lines)}")
print(f"Q4_LINE_COUNT={len(q4_lines)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 475.9 — CREATE Q3 / Q4 PROBES AND VERIFY"
  echo "==============================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Confirm probes were created"
  wc -l "$Q3" "$Q4"
  echo
  echo "--- Q3 PROBE HEADER ---"
  sed -n '1,40p' "$Q3"
  echo
  echo "--- Q4 PROBE HEADER ---"
  sed -n '1,40p' "$Q4"
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
    if curl -s --max-time 2 http://localhost:8080/dashboard_body_q3_probe.html >/dev/null 2>&1; then
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
  echo "--- GET /dashboard_body_q3_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_q3_probe.html 2>&1 || true
  echo
  echo "--- GET /dashboard_body_q4_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_q4_probe.html 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/dashboard_body_q3_probe.html | grep -q 'Q3 dashboard body probe' \
    && curl -s --max-time 5 http://localhost:8080/dashboard_body_q4_probe.html | grep -q 'Q4 dashboard body probe'; then
    echo "CLASSIFICATION: BOTTOM_HALF_QUARTER_PROBES_READY"
  else
    echo "CLASSIFICATION: BOTTOM_HALF_QUARTER_PROBES_NOT_SERVED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard_body_q3_probe.html first"
  echo "- Report EXACTLY one of:"
  echo "  • Q3_PROBE_STABLE"
  echo "  • Q3_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
