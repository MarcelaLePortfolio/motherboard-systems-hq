#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase473_3_extract_served_source_answer_and_verify_minimal_probe_route.txt"
SRC="docs/phase473_2_trace_actual_dashboard_html_source.txt"
SINCE_TS="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

mkdir -p docs

{
  echo "PHASE 473.3 — EXTRACT SERVED SOURCE ANSWER + VERIFY MINIMAL PROBE ROUTE"
  echo "======================================================================"
  echo
  echo "SINCE_TS: $SINCE_TS"
  echo

  echo "STEP 1 — Pull only the high-signal lines from phase473.2"
  rg -n "SENTINEL=|SENTINEL_PRESENT_IN_SERVED_DASHBOARD|SENTINEL_ABSENT_IN_SERVED_DASHBOARD|CLASSIFICATION:|served body size|RESTORE_BACKUP_FOUND|READY_ON_8080|HOST_8080_NOT_READY" "$SRC" || true
  echo

  echo "STEP 2 — Show the actual dashboard-serving lines from live server files only"
  rg -n 'express\.static|sendFile\(.*dashboard\.html|app\.get\("/dashboard"|app\.get\("/dashboard\.html"|res\.sendFile' server.mjs server.ts server routes/routes routes 2>/dev/null || true
  echo

  echo "STEP 3 — Confirm what exists inside the running container"
  docker compose exec -T dashboard sh -lc 'printf "\n-- /app/public/dashboard.html --\n"; wc -l /app/public/dashboard.html; printf "\n-- /app/public/minimal_probe.html --\n"; ls -l /app/public/minimal_probe.html 2>/dev/null || true; printf "\n-- public dir html files --\n"; find /app/public -maxdepth 1 -type f \( -name "*.html" -o -name "*.htm" \) | sort' 2>&1 || true
  echo

  echo "STEP 4 — If minimal_probe is missing in container, prove static file mount/build mismatch"
  docker compose exec -T dashboard sh -lc 'test -f /app/public/minimal_probe.html && echo CONTAINER_HAS_MINIMAL_PROBE || echo CONTAINER_MISSING_MINIMAL_PROBE' 2>&1 || true
  echo

  echo "STEP 5 — Fresh probe for dashboard + minimal probe"
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
  if docker compose exec -T dashboard sh -lc 'test -f /app/public/minimal_probe.html'; then
    echo "CLASSIFICATION: CONTAINER_SEES_NEW_PUBLIC_FILES"
  else
    echo "CLASSIFICATION: CONTAINER_NOT_USING_UPDATED_PUBLIC_TREE"
  fi
  echo

  echo "DECISION TARGET"
  echo "- If container is not using updated public tree, next step is container/public sync isolation."
  echo "- If container sees new files, next step is exact route precedence isolation."
} > "$OUT"

echo "Wrote $OUT"
sed -n '1,260p' "$OUT"
