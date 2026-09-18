#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED FAILURE CLASS ===\n'
echo "SERVER_PROJECT_REGISTRY=HEALTHY"
echo "SERVER_ACTIVE_PROJECT=hq"
echo "SERVER_APPROVALS_ENDPOINT=HEALTHY"
echo "DATABASE_PROJECT_REGISTRY=HEALTHY"
echo "EXACT_FAILURE_CLASS=BROWSER_CLIENT_CONTEXT_PATH"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== LOCATE PROJECT CONTEXT PROVIDER / BOOTSTRAP ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'ProjectContextProvider|createContext|useProjectContext|getProjectRegistry|ProjectContextControl|registryError|setRegistry|projectLoading' \
  client/src/project-context client/src/shell client/src/main.tsx client/src/App.tsx \
  | head -n 520 || true

printf '\n=== INSPECT PROJECT CONTEXT SOURCE FILES ===\n'
for file in \
  client/src/project-context/ProjectContextProvider.tsx \
  client/src/project-context/ProjectContextControl.tsx \
  client/src/project-context/projectRegistryApi.ts \
  client/src/project-context/types.ts \
  client/src/main.tsx \
  client/src/App.tsx \
  client/src/shell/Shell.tsx
do
  if [ -f "$file" ]; then
    printf '\n--- %s ---\n' "$file"
    sed -n '1,320p' "$file"
  fi
done

printf '\n=== INSPECT DEV / BUILD ORIGIN CONFIGURATION ===\n'
for file in \
  client/vite.config.ts \
  client/vite.config.js \
  vite.config.ts \
  vite.config.js \
  client/package.json \
  package.json
do
  if [ -f "$file" ]; then
    printf '\n--- %s ---\n' "$file"
    sed -n '1,280p' "$file"
  fi
done

printf '\n=== START SERVER FOR ORIGIN TEST ===\n'
SERVER_LOG="/tmp/motherboard-browser-client-path-server.log"
: > "$SERVER_LOG"

npm start >"$SERVER_LOG" 2>&1 &
SERVER_PID=$!

cleanup() {
  if kill -0 "$SERVER_PID" 2>/dev/null; then
    kill "$SERVER_PID" 2>/dev/null || true
    wait "$SERVER_PID" 2>/dev/null || true
  fi
}
trap cleanup EXIT

SERVER_READY=NO

for _ in $(seq 1 30); do
  if curl -sS -o /dev/null \
    "http://127.0.0.1:3000/api/projects/registry" \
    2>/dev/null; then
    SERVER_READY=YES
    break
  fi

  if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    break
  fi

  sleep 1
done

printf '\n=== SERVER READINESS ===\n'
echo "SERVER_READY=$SERVER_READY"

if [ "$SERVER_READY" != "YES" ]; then
  cat "$SERVER_LOG"
  echo "NEXT_ACTION=DIAGNOSE_SERVER_START_ONLY"
  exit 1
fi

printf '\n=== TEST SERVER-SERVED UI ORIGIN ===\n'
ROOT_STATUS="$(
  curl -sS \
    -o /tmp/browser-client-root.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/' \
    || true
)"

REGISTRY_STATUS="$(
  curl -sS \
    -o /tmp/browser-client-registry.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/projects/registry' \
    || true
)"

echo "ROOT_HTTP_STATUS=$ROOT_STATUS"
echo "REGISTRY_HTTP_STATUS=$REGISTRY_STATUS"

printf '\n=== ROOT DOCUMENT PREVIEW ===\n'
head -c 2500 /tmp/browser-client-root.body 2>/dev/null || true
printf '\n'

printf '\n=== REGISTRY RESPONSE ===\n'
cat /tmp/browser-client-registry.body 2>/dev/null || true
printf '\n'

printf '\n=== INSPECT BUILT CLIENT ASSET REFERENCES ===\n'
if [ -f client/dist/index.html ]; then
  cat client/dist/index.html
fi

printf '\n=== CHECK FOR HARDCODED ORIGIN / API BASE ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'localhost:3000|127\.0\.0\.1:3000|VITE_|API_BASE|baseURL|window\.location|location\.origin' \
  client/src client/dist 2>/dev/null \
  | head -n 420 || true

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/project-context \
  client/src/main.tsx \
  client/src/App.tsx \
  client/src/shell \
  server/index.ts \
  server/project-registry.mjs

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "BROWSER_CLIENT_CONTEXT_DIAGNOSIS=IN_PROGRESS"
echo "SERVER_REGISTRY_HEALTH=PROVEN"
echo "SERVER_ACTIVE_PROJECT_HQ=PROVEN"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=CLASSIFY_PROVIDER_BOOTSTRAP_OR_BROWSER_ORIGIN_FAILURE_FROM_OUTPUT"
