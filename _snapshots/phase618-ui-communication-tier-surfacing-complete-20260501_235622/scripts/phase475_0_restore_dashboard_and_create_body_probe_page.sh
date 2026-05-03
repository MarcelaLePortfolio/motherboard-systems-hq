#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

HTML="public/dashboard.html"
RESTORE_CANDIDATES=(
  "public/dashboard.html.phase474_9_pre_body_isolation.bak"
  "public/dashboard.html.phase474_4_pre_inline_style_neutralization.bak"
  "public/dashboard.html.phase474_3_pre_force_tailwind_only.bak"
  "public/dashboard.html.phase474_2_pre_tailwind_only_restore.bak"
  "public/dashboard.html.phase473_9_pre_styles_restore.bak"
)
PROBE="public/body_isolation_probe.html"
OUT="docs/phase475_0_restore_dashboard_and_create_body_probe_page.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs public

RESTORED_FROM=""
for candidate in "${RESTORE_CANDIDATES[@]}"; do
  if [ -f "$candidate" ]; then
    cp "$candidate" "$HTML"
    RESTORED_FROM="$candidate"
    break
  fi
done

if [ -z "$RESTORED_FROM" ]; then
  echo "No dashboard restore candidate found."
  exit 1
fi

cat > "$PROBE" <<'EOT'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Body Isolation Probe</title>
  <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet" />
</head>
<body class="min-h-screen bg-white text-slate-900">
  <main class="max-w-3xl mx-auto px-6 py-10">
    <h1 class="text-3xl font-bold mb-4">Body Isolation Probe</h1>
    <p class="text-base mb-3">
      This page exists to isolate whether the browser freeze is caused by the dashboard body markup itself.
    </p>
    <p class="text-base mb-3">
      It uses a separate route and does not depend on the dashboard body structure.
    </p>
    <p class="text-sm text-slate-600">
      Phase 475.0 keeps dashboard.html restored while serving this separate probe page.
    </p>
  </main>
</body>
</html>
EOT

{
  echo "PHASE 475.0 — RESTORE DASHBOARD AND CREATE BODY PROBE PAGE"
  echo "=========================================================="
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Dashboard restored from backup"
  echo "RESTORED_FROM=$RESTORED_FROM"
  wc -l "$HTML" || true
  echo

  echo "STEP 2 — Body probe page created"
  wc -l "$PROBE" || true
  sed -n '1,80p' "$PROBE"
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
    if curl -s --max-time 2 http://localhost:8080/body_isolation_probe.html >/dev/null 2>&1; then
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
  echo "--- GET /dashboard.html ---"
  curl -I --max-time 5 http://localhost:8080/dashboard.html 2>&1 || true
  echo
  echo "--- GET /body_isolation_probe.html ---"
  curl -i --max-time 5 http://localhost:8080/body_isolation_probe.html 2>&1 || true
  echo

  echo "STEP 7 — Fresh dashboard logs"
  docker compose logs --since "$SINCE_TS" dashboard 2>&1 || true
  echo

  echo "STEP 8 — Classification"
  if [ "$READY" -ne 1 ]; then
    echo "CLASSIFICATION: HOST_8080_NOT_READY"
  elif curl -s --max-time 5 http://localhost:8080/body_isolation_probe.html | grep -q "Body Isolation Probe"; then
    echo "CLASSIFICATION: DASHBOARD_RESTORED_AND_BODY_PROBE_READY"
  else
    echo "CLASSIFICATION: BODY_PROBE_NOT_SERVED"
  fi
  echo

  echo "DECISION TARGET"
  echo "- Open http://localhost:8080/body_isolation_probe.html"
  echo "- Report EXACTLY:"
  echo "  • BODY_PROBE_STABLE"
  echo "  • BODY_PROBE_STILL_UNRESPONSIVE"
  echo "  • WHITE_SCREEN_RETURNED"
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,220p' "$OUT"
