#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_served_dashboard_html_confidence_label_${STAMP}.txt"

TARGETS=(
  "public/dashboard.html"
  "dashboard/public/dashboard.html"
)

python3 - <<'PY'
from pathlib import Path
import sys

targets = [
    Path("public/dashboard.html"),
    Path("dashboard/public/dashboard.html"),
]

patched = []

for path in targets:
    if not path.exists():
        continue
    text = path.read_text(errors="ignore")
    original = text

    replacements = [
        ("Confidence: insufficient", "Confidence: limited"),
        ('>insufficient<', '>limited<'),
        ('"insufficient"', '"limited"'),
        ("'insufficient'", "'limited'"),
    ]

    for old, new in replacements:
        text = text.replace(old, new)

    if text != original:
        path.write_text(text)
        patched.append(str(path))

if not patched:
    print("No served dashboard HTML confidence label targets patched.", file=sys.stderr)
    sys.exit(1)

print("patched_files=" + ",".join(patched))
PY

{
  echo "PHASE 487 — PATCH SERVED DASHBOARD HTML CONFIDENCE LABEL"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== TARGET CHECK ==="
  rg -n -C 3 "Confidence:|limited|insufficient|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|diagnostics/system-health" public/dashboard.html dashboard/public/dashboard.html 2>/dev/null || true
  echo

  echo "=== PM2 RESTART ==="
  pm2 restart all 2>&1 || true
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo
} > "${OUT}"

echo "${OUT}"
