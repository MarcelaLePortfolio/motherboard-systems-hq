#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESTORE_SRC="public/dashboard.html.phase473_0_minimal_shell_backup.bak"
DASH_HTML="public/dashboard.html"
MINIMAL_HTML="public/minimal_probe.html"
OUT="docs/phase473_1_restore_dashboard_and_create_minimal_probe_page.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public

if [ -f "$RESTORE_SRC" ]; then
  cp "$RESTORE_SRC" "$DASH_HTML"
fi

cat > "$MINIMAL_HTML" <<'EOT'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Minimal Probe Page</title>
</head>
<body>
  <h1>Minimal Probe Page</h1>
  <p>If this page stays responsive, the browser freeze is specific to dashboard markup or dashboard delivery shape.</p>
</body>
</html>
EOT

{
  echo "PHASE 473.1 — RESTORE DASHBOARD AND CREATE MINIMAL PROBE PAGE"
  echo "============================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Dashboard restoration check"
  if [ -f "$RESTORE_SRC" ]; then
    echo "RESTORE_BACKUP_FOUND"
    wc -l "$DASH_HTML"
  else
    echo "RESTORE_BACKUP_MISSING"
  fi
  echo

  echo "STEP 2 — Minimal probe page check"
  wc -l "$MINIMAL_HTML"
  sed -n '1,40p' "$MINIMAL_HTML"
  echo

  echo "STEP 3 — Restart dashboard"
  docker compose restart dashboard 2>&1 || true
  echo

  echo "STEP 4 — Wait for host port 8080 readiness"
  READY=0
  for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
    if curl -s --max-time 2 http://localhost:8080/minimal_probe.html >/dev/null 2>&1; then
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

  echo "STEP 5 — Probe restored dashboard and minimal page"
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /minimal_probe.html ---"
  curl -I --max-time 5 http://localhost:8080/minimal_probe.html 2>&1 || true
  echo

  echo "STEP 6 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 7 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: MINIMAL_PROBE_PAGE_READY_WITH_DASHBOARD_RESTORED"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/minimal_probe.html"
  echo "- Report exactly one of:"
  echo "  • MINIMAL_PROBE_STABLE"
  echo "  • MINIMAL_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,240p' "$OUT"
