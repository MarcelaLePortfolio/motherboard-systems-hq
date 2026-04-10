#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_2_trace_actual_dashboard_html_source.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 473.2 — TRACE ACTUAL DASHBOARD HTML SOURCE"
  echo "==============================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Search repo for dashboard.html serving logic"
  rg -n "dashboard\\.html|sendFile\\(|express\\.static|res\\.sendFile|app\\.use\\(|router\\.get\\(" server routes src . --glob '!node_modules' --glob '!docs' || true
  echo

  echo "STEP 2 — Find all dashboard.html files on disk"
  find . -type f -name 'dashboard.html' -o -type f -name 'dashboard*.html' | sort
  echo

  echo "STEP 3 — Show checksums + sizes for dashboard-like html files"
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    printf '%s | ' "$f"
    wc -c < "$f" | tr -d '\n'
    printf ' bytes | '
    shasum "$f" | awk '{print $1}'
  done < <(find . -type f \( -name 'dashboard.html' -o -name 'dashboard*.html' \) | sort)
  echo

  echo "STEP 4 — Inject unique sentinel into public/dashboard.html only"
  SENTINEL="PHASE4732_SENTINEL_$(date -u +%s)"
  export SENTINEL
  python3 - <<'PY'
from pathlib import Path
import os
p = Path("public/dashboard.html")
text = p.read_text()
needle = "</body>"
sentinel = os.environ["SENTINEL"]
insert = f'  <!-- {sentinel} -->\n'
if sentinel not in text:
    if needle in text:
        text = text.replace(needle, insert + needle, 1)
    else:
        text += "\n" + insert
p.write_text(text)
PY
  echo "SENTINEL=$SENTINEL"
  echo

  echo "STEP 5 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo
  sleep 5
  echo

  echo "STEP 6 — Fetch served dashboard body and search for sentinel"
  curl -s --max-time 10 http://localhost:8080/dashboard.html > /tmp/phase4732_dashboard_served.html || true
  echo "--- served body size ---"
  wc -c /tmp/phase4732_dashboard_served.html || true
  echo "--- sentinel present in served body? ---"
  if rg -q "$SENTINEL" /tmp/phase4732_dashboard_served.html; then
    echo "SENTINEL_PRESENT_IN_SERVED_DASHBOARD"
  else
    echo "SENTINEL_ABSENT_IN_SERVED_DASHBOARD"
  fi
  echo
  echo "--- served title/head excerpt ---"
  sed -n '1,80p' /tmp/phase4732_dashboard_served.html || true
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if rg -q "$SENTINEL" /tmp/phase4732_dashboard_served.html; then
    echo "CLASSIFICATION: PUBLIC_DASHBOARD_HTML_IS_SERVED_SOURCE"
  else
    echo "CLASSIFICATION: DASHBOARD_HTML_IS_SERVED_FROM_SOMEWHERE_ELSE"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Next mutation must target the ACTUAL served dashboard source, not public/dashboard.html, if sentinel is absent."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
