#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TOP_RESULT="${1:-}"
TOP_NOTE="${2:-}"
SRC="public/dashboard_body_top_half_probe.html"
Q1="public/dashboard_body_q1_probe.html"
Q2="public/dashboard_body_q2_probe.html"
OUT="docs/phase475_4_record_top_half_result_and_create_quarter_probes.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

if [ -z "$TOP_RESULT" ]; then
  echo "Usage:"
  echo '  ./scripts/phase475_4_record_top_half_result_and_create_quarter_probes.sh TOP_HALF_PROBE_STABLE'
  echo '  ./scripts/phase475_4_record_top_half_result_and_create_quarter_probes.sh TOP_HALF_PROBE_STILL_UNRESPONSIVE "optional note"'
  echo '  ./scripts/phase475_4_record_top_half_result_and_create_quarter_probes.sh WHITE_SCREEN_RETURNED "optional note"'
  exit 1
fi

case "$TOP_RESULT" in
  TOP_HALF_PROBE_STABLE|TOP_HALF_PROBE_STILL_UNRESPONSIVE|WHITE_SCREEN_RETURNED)
    ;;
  *)
    echo "Invalid result: $TOP_RESULT"
    exit 1
    ;;
esac

mkdir -p docs public

cat > docs/phase475_4_top_half_probe_result.txt <<EOT
PHASE 475.4 — TOP HALF PROBE RESULT
===================================

RESULT:
$TOP_RESULT

OPTIONAL_NOTE:
$TOP_NOTE
EOT

python3 - <<'PY'
from pathlib import Path
import re

src = Path("public/dashboard_body_top_half_probe.html").read_text()

head_match = re.search(r'(<head\b[^>]*>.*?</head>)', src, re.IGNORECASE | re.DOTALL)
body_match = re.search(r'<body\b[^>]*>(.*?)</body>', src, re.IGNORECASE | re.DOTALL)

if not head_match or not body_match:
    raise SystemExit("Could not extract head/body from top-half probe")

head = head_match.group(1)
body_inner = body_match.group(1)
lines = body_inner.splitlines()

marker_idx = 0
for i, line in enumerate(lines):
    if "top half dashboard body probe" in line:
        marker_idx = i + 1
        break

content_lines = lines[marker_idx:]
if not content_lines:
    raise SystemExit("No content lines found after top-half marker")

mid = max(1, len(content_lines) // 2)
q1_lines = "\n".join(content_lines[:mid]).strip()
q2_lines = "\n".join(content_lines[mid:]).strip()

q1_html = f"""<!DOCTYPE html>
<html lang="en">
{head}
<body>
<div style="padding: 12px; font-family: sans-serif;">
  <p><strong>Phase 475.4:</strong> Q1 dashboard body probe</p>
</div>
{q1_lines}
</body>
</html>
"""

q2_html = f"""<!DOCTYPE html>
<html lang="en">
{head}
<body>
<div style="padding: 12px; font-family: sans-serif;">
  <p><strong>Phase 475.4:</strong> Q2 dashboard body probe</p>
</div>
{q2_lines}
</body>
</html>
"""

Path("public/dashboard_body_q1_probe.html").write_text(q1_html)
Path("public/dashboard_body_q2_probe.html").write_text(q2_html)

print(f"TOP_HALF_CONTENT_LINE_COUNT={len(content_lines)}")
print(f"Q1_LINE_COUNT={len(content_lines[:mid])}")
print(f"Q2_LINE_COUNT={len(content_lines[mid:])}")
PY

{
  echo "PHASE 475.4 — RECORD TOP HALF RESULT AND CREATE QUARTER PROBES"
  echo "=============================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Recorded top-half result"
  sed -n '1,120p' docs/phase475_4_top_half_probe_result.txt
  echo

  echo "STEP 2 — Quarter probes created from top-half content"
  wc -l "$Q1" || true
  wc -l "$Q2" || true
  echo
  echo "--- Q1 PROBE HEADER ---"
  sed -n '1,40p' "$Q1" || true
  echo
  echo "--- Q2 PROBE HEADER ---"
  sed -n '1,40p' "$Q2" || true
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
    if curl -s --max-time 2 http://localhost:8080/dashboard_body_q1_probe.html >/dev/null 2>&1; then
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

  echo "STEP 6 — Probe routes"
  echo "--- GET /dashboard_body_q1_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_q1_probe.html 2>&1 || true
  echo
  echo "--- GET /dashboard_body_q2_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard_body_q2_probe.html 2>&1 || true
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/dashboard_body_q1_probe.html | grep -q 'Q1 dashboard body probe' \
    && curl -s --max-time 5 http://localhost:8080/dashboard_body_q2_probe.html | grep -q 'Q2 dashboard body probe'; then
    echo "CLASSIFICATION: TOP_HALF_QUARTER_PROBES_READY"
  else
    echo "CLASSIFICATION: TOP_HALF_QUARTER_PROBES_NOT_SERVED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard_body_q1_probe.html first"
  echo "- Report EXACTLY one of:"
  echo "  • Q1_PROBE_STABLE"
  echo "  • Q1_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
