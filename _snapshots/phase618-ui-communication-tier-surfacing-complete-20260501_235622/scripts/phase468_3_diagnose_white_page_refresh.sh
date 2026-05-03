#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

OUT="docs/phase468_3_white_page_refresh_diagnosis.txt"

mkdir -p docs

{
  echo "PHASE 468.3 — WHITE PAGE REFRESH DIAGNOSIS"
  echo "=========================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo "Repo root: $(pwd)"
  echo

  echo "STEP 1 — Container state"
  docker compose ps 2>&1 || true
  echo

  echo "STEP 2 — Root and dashboard probe"
  echo "--- GET / ---"
  curl -i --max-time 5 http://localhost:3000/ 2>&1 || true
  echo
  echo "--- GET /dashboard ---"
  curl -i --max-time 5 http://localhost:3000/dashboard 2>&1 || true
  echo

  echo "STEP 3 — Static asset probe"
  for path in \
    /bundle.js \
    /dashboard.html \
    /js/dashboard-delegation.js \
    /js/matilda-chat-console.js
  do
    echo "--- GET ${path} ---"
    curl -i --max-time 5 "http://localhost:3000${path}" 2>&1 || true
    echo
  done

  echo "STEP 4 — Recent dashboard logs"
  docker compose logs --tail=200 dashboard 2>&1 || true
  echo

  echo "STEP 5 — Browser-surface failure signatures in source"
  rg -n "window\\.location|historyApiFallback|dashboard\\.html|bundle\\.js|Content-Type|express\\.static|sendFile|Not Found|Cannot GET /dashboard|white page|loading" \
    server src public 2>/dev/null || true
  echo

  echo "STEP 6 — HTML entrypoint inventory"
  find public -maxdepth 2 \( -name "*.html" -o -name "*.js" \) | sort
  echo

  echo "STEP 7 — Decision target"
  echo "- If /dashboard fails but / works: route/entrypoint issue."
  echo "- If HTML loads but bundle.js fails: asset serving issue."
  echo "- If both load but logs show runtime error: front-end boot failure."
  echo "- If dashboard container is unhealthy: service boot failure."
} > "$OUT"

echo "Wrote $OUT"
