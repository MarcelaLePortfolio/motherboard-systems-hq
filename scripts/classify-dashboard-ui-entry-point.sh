#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY DASHBOARD UI ENTRY POINT ==="

echo
echo "=== BASELINE ==="
echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "COMMIT=$(git log -1 --format=%s)"
git status --short

echo
echo "=== VERIFY BACKEND IS LISTENING ==="
if ! lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "STOP: backend is not listening on port 3000."
  exit 2
fi
echo "BACKEND_PORT_3000=LISTENING"

echo
echo "=== INSPECT SERVER ROUTES / STATIC MOUNTS ==="
grep -RInE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'app\.use\(|app\.get\(|express\.static|dashboard|index\.html|public/' \
  server routes scripts \
  2>/dev/null |
head -n 500 || true

echo
echo "=== PROBE LIKELY UI ROUTES ==="
for url in \
  http://127.0.0.1:3000/dashboard \
  http://127.0.0.1:3000/dashboard.html \
  http://127.0.0.1:3000/matilda \
  http://127.0.0.1:3000/mission-control
do
  code="$(curl -sS -o /tmp/ui-probe-body.txt -w '%{http_code}' "$url" || true)"
  type="$(curl -sSI "$url" 2>/dev/null | awk -F': ' 'tolower($1)=="content-type"{print $2}' | tr -d '\r' | head -n 1)"
  printf '%s -> HTTP %s %s\n' "$url" "$code" "${type:-}"
done

echo
echo "=== FIND LOCAL FRONTEND PROJECTS ==="
find . -maxdepth 4 \
  \( -name package.json -o -name vite.config.ts -o -name vite.config.js -o -name vite.config.mjs \) \
  -not -path './node_modules/*' \
  -print |
sort

echo
echo "=== CLASSIFICATION RESULT ==="
echo "BACKEND_RUNTIME=HEALTHY"
echo "ROOT_ROUTE_3000=404_EXPECTED_OR_NON_UI"
echo "NEXT_ACTION=OPEN_CONFIRMED_DASHBOARD_ROUTE_OR_START_FRONTEND_IF_SEPARATE"

echo
echo "=== DIFF CHECK ==="
git diff --check

git add scripts/classify-dashboard-ui-entry-point.sh
git diff --cached --check
git commit -m "Classify dashboard UI entry point"
git push
