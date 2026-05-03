#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase471_0_task_events_surface_neutralized.bak"
OUT="docs/phase471_0_task_events_surface_neutralization.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

cp "$HTML" "$BACKUP"

python3 - <<'PY'
from pathlib import Path

html_path = Path("public/dashboard.html")
text = html_path.read_text()

replacements = [
    (
        '<script src="js/phase457_restore_task_panels.js"></script>',
        '<!-- phase471.0 temporary neutralization: phase457_restore_task_panels.js removed to isolate task-events surface -->'
    ),
]

for old, new in replacements:
    if old in text:
        text = text.replace(old, new, 1)

html_path.write_text(text)
PY

{
  echo "PHASE 471.0 — NEUTRALIZE TASK-EVENTS SURFACE AND VERIFY"
  echo "======================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm task-events surface script neutralized"
  rg -n "phase457_restore_task_panels\\.js|phase471\\.0 temporary neutralization" "$HTML" || true
  echo

  echo "STEP 2 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo

  echo "STEP 3 — Wait for host port 8080 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if curl -s --max-time 2 http://localhost:8080/dashboard.html >/dev/null 2>&1; then
      READY=1
      echo "READY_ON_8080 attempt=$i"
      break
    fi
    sleep 2
  done
  if [ "$READY" -ne 1 ]; then
    echo "HOST_8080_NOT_READY_AFTER_WAIT"
  fi
  echo

  echo "STEP 4 — Fresh probes"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /bundle.js ---"
  curl -I --max-time 5 http://localhost:8080/bundle.js 2>&1 || true
  echo
  echo "--- GET /events/task-events ---"
  curl -I --max-time 5 http://localhost:8080/events/task-events 2>&1 || true
  echo

  echo "STEP 5 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 6 — Classification"
  LOGS="$(docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true)"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif echo "$LOGS" | rg -q '\[HTTP\] GET /js/phase457_restore_task_panels\.js'; then
    echo "CLASSIFICATION: TASK_EVENTS_SURFACE_SCRIPT_STILL_REQUESTED"
  else
    echo "CLASSIFICATION: TASK_EVENTS_SURFACE_NEUTRALIZED_FOR_FREEZE_ISOLATION"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html and observe for 60–90 seconds."
  echo "- Report exactly one of: STABLE_AFTER_TASK_EVENTS_NEUTRALIZATION / STILL_FREEZES / WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
