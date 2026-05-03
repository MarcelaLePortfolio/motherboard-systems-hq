#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
BACKUP="public/dashboard.html.phase473_0_minimal_shell_backup.bak"
OUT="docs/phase473_0_minimal_html_shell_verification.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

cp "$HTML" "$BACKUP"

cat > "$HTML" <<'EOT'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Minimal Test Shell</title>
</head>
<body>
  <h1>Minimal HTML Shell</h1>
  <p>If this freezes, the issue is NOT your app code.</p>
</body>
</html>
EOT

{
  echo "PHASE 473.0 — FORCE MINIMAL HTML SHELL AND VERIFY"
  echo "================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Confirm minimal HTML written"
  sed -n '1,40p' "$HTML"
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

  echo "STEP 4 — Probe"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo

  echo "STEP 5 — Logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 6 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  else
    echo "CLASSIFICATION: MINIMAL_HTML_READY_FOR_FINAL_ISOLATION"
  fi

  echo
  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/dashboard.html"
  echo "- Report exactly one of:"
  echo "  • MINIMAL_HTML_STABLE"
  echo "  • MINIMAL_HTML_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,200p' "$OUT"
