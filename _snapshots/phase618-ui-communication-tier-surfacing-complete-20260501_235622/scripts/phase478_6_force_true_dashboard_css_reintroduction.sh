#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET="public/dashboard.html"
BACKUP="public/dashboard.html.phase478_6_pre_true_dashboard_css_restore.bak"
OUT="docs/phase478_6_force_true_dashboard_css_reintroduction.txt"

mkdir -p docs
cp "$TARGET" "$BACKUP"

python3 <<'PY'
from pathlib import Path
import re
import sys

target_path = Path("public/dashboard.html")
text = target_path.read_text()

comment_line = '<!-- phase474.3 temporary neutralization: removed local stylesheet :: <link rel="stylesheet" href="css/dashboard.css?v=darkmode" /> -->'
active_line = '<link rel="stylesheet" href="css/dashboard.css?v=darkmode" />'

report = []
report.append("PHASE 478.6 — FORCE TRUE dashboard.css REINTRODUCTION")
report.append("====================================================")
report.append("")

if re.search(r'(?im)^\s*<link[^>]*href=["\']css/dashboard\.css\?v=darkmode["\'][^>]*>\s*$', text):
    report.append("ACTIVE_DASHBOARD_CSS_ALREADY_PRESENT=1")
elif comment_line in text:
    text = text.replace(comment_line, active_line, 1)
    target_path.write_text(text)
    report.append("COMMENTED_DASHBOARD_CSS_ACTIVATED=1")
elif 'css/dashboard.css?v=darkmode' in text:
    report.append("DASHBOARD_CSS_REFERENCE_PRESENT_ONLY_IN_NONSTANDARD_FORM=1")
    report.append("MANUAL_REVIEW_NEEDED=1")
else:
    head_close = re.search(r'(?i)</head>', text)
    if not head_close:
        report.append("ERROR: could not find </head> insertion point")
        Path("docs/phase478_6_force_true_dashboard_css_reintroduction.txt").write_text("\n".join(report) + "\n")
        print("ERROR: could not find </head> insertion point", file=sys.stderr)
        sys.exit(1)
    text = text[:head_close.start()] + active_line + "\n" + text[head_close.start():]
    target_path.write_text(text)
    report.append("DASHBOARD_CSS_INSERTED_FRESH=1")

report.append("")
report.append("ACTIVE STYLESHEET LINES AFTER MUTATION")
for line in target_path.read_text().splitlines():
    if "<link" in line and "stylesheet" in line:
        report.append(line)

Path("docs/phase478_6_force_true_dashboard_css_reintroduction.txt").write_text("\n".join(report) + "\n")
print("\n".join(report))
PY

SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

{
  echo
  echo "STEP 1 — Backup created"
  echo "$BACKUP"
  echo
  echo "STEP 2 — Mutation report"
  sed -n '1,220p' "$OUT"
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
    echo "CLASSIFICATION: TRUE_DASHBOARD_CSS_REINTRODUCED"
  fi
  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report EXACTLY one of:"
  echo "  • TRUE_DASHBOARD_CSS_STABLE"
  echo "  • TRUE_DASHBOARD_CSS_BREAKS"
  echo "  • WHITE_SCREEN_RETURNED"
} >> "$OUT"

echo "Wrote $OUT"
sed -n '1,300p' "$OUT"
