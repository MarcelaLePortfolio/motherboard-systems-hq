#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase477_2_pre_probe_banner_removal.bak"
OUT="docs/phase477_2_remove_probe_banners_from_stable_dashboard.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re

target = Path("public/dashboard.html")
text = target.read_text()

patterns = [
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 476\.3:</strong>\s*recomposed full-body probe from stable Q1 \+ Q2 \+ Q3 \+ Q4 fragments</p>\s*</div>\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.4:</strong>\s*Q1 dashboard body probe</p>\s*</div>\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.3:</strong>\s*top half dashboard body probe</p>\s*</div>\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.4:</strong>\s*Q2 dashboard body probe</p>\s*</div>\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.9:</strong>\s*Q3 dashboard body probe</p>\s*</div>\s*',
    r'\s*<!-- phase475\.3 bottom half dashboard body probe -->\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.3:</strong>\s*bottom half dashboard body probe</p>\s*</div>\s*',
    r'\s*<div style="padding: 12px; font-family: sans-serif;">\s*<p><strong>Phase 475\.9:</strong>\s*Q4 dashboard body probe</p>\s*</div>\s*',
]

original = text
removed = 0
for pattern in patterns:
    text, count = re.subn(pattern, "\n", text, flags=re.S)
    removed += count

text = re.sub(r'\n{3,}', '\n\n', text)
text = re.sub(r'</head>\s*<body', '</head>\n<body', text, flags=re.S)
text = re.sub(r'</body>\s*</html>', '</body>\n</html>', text, flags=re.S)

target.write_text(text)
print(f"PROBE_BANNERS_REMOVED={removed}")
print(f"ORIGINAL_LEN={len(original)}")
print(f"NEW_LEN={len(text)}")
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo "PHASE 477.2 — REMOVE PROBE BANNERS FROM STABLE DASHBOARD"
  echo "========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo
  echo "STEP 1 — Backup"
  echo "$BACKUP"
  echo
  echo "STEP 2 — Dashboard head/body opening after banner removal"
  sed -n '20,45p' "$TARGET"
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
    echo "CLASSIFICATION: STABLE_DASHBOARD_WITH_PROBE_BANNERS_REMOVED_READY"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • BANNER_REMOVAL_STABLE"
  echo "  • BANNER_REMOVAL_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
