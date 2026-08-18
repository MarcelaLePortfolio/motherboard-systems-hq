#!/usr/bin/env bash
set -euo pipefail

echo "=== MATILDA UI — ENTRY ROUTE DIAGNOSIS ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"

echo
echo "=== SERVER LISTENER ==="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true

echo
echo "=== ROOT / STATIC / UI ROUTES ==="
grep -RInE \
  "app\.(get|use)\(|router\.(get|use)\(|express\.static|sendFile|index\.html|dashboard|atlas|matilda|ui" \
  server routes \
  --exclude-dir=node_modules \
  | head -n 250 || true

echo
echo "=== COMMON LOCAL ENDPOINT CHECK ==="
for path in / /dashboard /matilda /atlas /app /ui /health /api/health; do
  status="$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:3000${path}" || true)"
  echo "${path} -> ${status}"
done

echo
echo "DIAGNOSIS_ONLY=YES"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=OPEN_THE_CONFIRMED_UI_ROUTE_OR_IDENTIFY_THE_FRONTEND_SERVER_IF_PORT_3000_IS_API_ONLY"
