#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DIAGNOSE BLANK UI AFTER PROJECT CONTEXT RESTORATION ==="
echo "BASELINE_COMMIT=7755e419"
echo "OBSERVED_UI=BLANK_PAGE"
echo "PROJECT_CONTEXT_API=RESTORED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CLIENT BUILD VALIDATION ==="
(
  cd client
  npm run build
)

echo
echo "=== VITE ROOT DOCUMENTS ==="
for port in 5173 5174; do
  body="/tmp/motherboard-vite-root-${port}.html"
  code="$(curl -sS -o "$body" -w '%{http_code}' "http://localhost:${port}/" || true)"
  echo "VITE_${port}_ROOT_HTTP_STATUS=${code}"
  head -c 700 "$body" 2>/dev/null || true
  echo
done

echo
echo "=== CLIENT ENTRYPOINT / PROVIDER TREE ==="
rg -n -C 12 \
  'createRoot|ReactDOM|ProjectContextProvider|MissionControlProvider|App|StrictMode' \
  client/src \
  -g '*.tsx' -g '*.ts' \
  2>/dev/null || true

echo
echo "=== PROJECT CONTEXT / RENDER FAILURE SURFACES ==="
rg -n -C 8 \
  'throw new Error|useProjectContext|ProjectContext|activeProjectId|registry' \
  client/src \
  -g '*.tsx' -g '*.ts' \
  2>/dev/null || true

echo
echo "=== RECENT CLIENT SOURCE DIFF ==="
git diff 5191d545..HEAD -- client/src | sed -n '1,500p'

echo
echo "=== VITE PROCESS STATE ==="
lsof -nP -iTCP -sTCP:LISTEN | rg '5173|5174|node' || true
ps aux | rg 'client/node_modules/.bin/vite' | rg -v 'rg ' || true

echo
echo "=== VITE PROCESS WORKING DIRECTORIES ==="
for pid in $(pgrep -f 'client/node_modules/.bin/vite' || true); do
  echo "--- PID ${pid} ---"
  lsof -a -p "$pid" -d cwd 2>/dev/null || true
done

echo
echo "=== CURRENT API HEALTH ==="
curl -sS -w '\nPROJECT_REGISTRY_HTTP_STATUS=%{http_code}\n' \
  http://localhost:3000/api/projects/registry || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "BLANK_PAGE_CAUSE=NOT_YET_CLASSIFIED"
echo "PROJECT_CONTEXT_API_UNAVAILABLE=NO"
echo "CLIENT_BUILD_FAILURE_IF_PRESENT=ACTIONABLE"
echo "CLIENT_RUNTIME_OR_STALE_VITE_PROCESS_IF_BUILD_PASSES=NEXT_CLASSIFICATION"
echo "CLIENT_SOURCE_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_BLANK_PAGE_AS_BUILD_ERROR_RUNTIME_RENDER_EXCEPTION_OR_STALE_DEV_SERVER_FROM_OUTPUT"
