#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase476_3_recompose_stable_quarters_into_full_probe.txt"
TARGET="public/dashboard_recomposed_from_stable_quarters_probe.html"

mkdir -p docs

python3 <<'PY'
from pathlib import Path
import re

q1 = Path("public/dashboard_body_q1_probe.html").read_text()
q2 = Path("public/dashboard_body_q2_probe.html").read_text()
q3 = Path("public/dashboard_body_q3_probe.html").read_text()
q4 = Path("public/dashboard_body_q4_probe.html").read_text()
target = Path("public/dashboard_recomposed_from_stable_quarters_probe.html")

def split_doc(text: str):
    m = re.search(r"(?is)(.*?<body[^>]*>)(.*?)(</body>.*)", text)
    if not m:
        raise SystemExit("Could not locate <body>...</body> structure.")
    return m.group(1), m.group(2), m.group(3)

head_open, q1_body, tail = split_doc(q1)
_, q2_body, _ = split_doc(q2)
_, q3_body, _ = split_doc(q3)
_, q4_body, _ = split_doc(q4)

def strip_probe_banner(body: str) -> str:
    body = re.sub(
        r'^\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase [^<]+</strong>:\s*Q[1-4] dashboard body probe</p>\s*</div>\s*',
        '',
        body,
        flags=re.S,
    )
    return body

q1_body = strip_probe_banner(q1_body)
q2_body = strip_probe_banner(q2_body)
q3_body = strip_probe_banner(q3_body)
q4_body = strip_probe_banner(q4_body)

banner = """
<div style="padding: 12px; font-family: sans-serif;">
  <p><strong>Phase 476.3:</strong> recomposed full-body probe from stable Q1 + Q2 + Q3 + Q4 fragments</p>
</div>
""".strip()

recomposed_body = "\n".join([banner, q1_body, q2_body, q3_body, q4_body])
target.write_text(head_open + recomposed_body + tail)

print(f"RECOMPOSED_TARGET={target}")
print(f"Q1_BODY_LEN={len(q1_body)}")
print(f"Q2_BODY_LEN={len(q2_body)}")
print(f"Q3_BODY_LEN={len(q3_body)}")
print(f"Q4_BODY_LEN={len(q4_body)}")
print(f"RECOMPOSED_TOTAL_LEN={len(recomposed_body)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 476.3 — RECOMPOSE STABLE QUARTERS INTO FULL PROBE"
  echo "======================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm recomposed probe was created"
  wc -l "$TARGET"
  echo
  sed -n '1,60p' "$TARGET"
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
    if curl -s --max-time 2 http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html >/dev/null 2>&1; then
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

  echo "STEP 5 — Probe recomposed route"
  curl -I --max-time 5 http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html | grep -q 'recomposed full-body probe from stable Q1 + Q2 + Q3 + Q4 fragments'; then
    echo "CLASSIFICATION: RECOMPOSED_FULL_BODY_PROBE_READY"
  else
    echo "CLASSIFICATION: RECOMPOSED_FULL_BODY_PROBE_NOT_SERVED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard_recomposed_from_stable_quarters_probe.html"
  echo "- Report EXACTLY one of:"
  echo "  • RECOMPOSED_PROBE_STABLE"
  echo "  • RECOMPOSED_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
