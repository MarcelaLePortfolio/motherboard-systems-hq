#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

printf '\n=== BASELINE ===\n'
git fetch origin "$BRANCH"
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "HEAD=$(git rev-parse HEAD)"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"

printf '\n=== PRESERVE KNOWN STATE ===\n'
echo "ATLAS_PERSISTENCE_CORRIDOR=CLOSED"
echo "ATLAS_LIVE_DOGFOOD_PERSISTENCE=PROVEN"
echo "ATLAS_CONVERSATION_SCOPED_READBACK=PROVEN"
echo "NEW_BROWSER_SYMPTOM=HTTP_404"
echo "DIAGNOSTIC_SCOPE=ATLAS_HTTP_ROUTE_MOUNT_AND_BROWSER_PROXY_ONLY"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

printf '\n=== CLIENT REQUEST CONTRACT ===\n'
grep -n -A12 -B8 \
  'atlas/preexecution' \
  client/src/atlas/atlasPreexecutionApi.ts || true

printf '\n=== SERVER ROUTE DEFINITION ===\n'
grep -n -A45 -B15 \
  'atlas/preexecution' \
  server/routes/atlas/preexecution.ts || true

printf '\n=== SERVER MOUNT ===\n'
grep -n -A15 -B15 \
  -E 'atlasPreExecutionRouter|preexecution' \
  server/index.ts || true

printf '\n=== VITE PROXY CONTRACT ===\n'
grep -n -A50 -B10 \
  -E 'proxy|/api|atlas' \
  client/vite.config.ts || true

printf '\n=== LIVE BACKEND DIRECT PROBE ===\n'
BACKEND_STATUS="$(
  curl -sS \
    -o /tmp/atlas-backend-404.body \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/atlas/preexecution?project_id=hq&conversation_id=matilda-conversation-hq-1789754980083-t80g6h' \
    2>/dev/null || true
)"
echo "BACKEND_ATLAS_HTTP_STATUS=${BACKEND_STATUS:-000}"
echo "BACKEND_ATLAS_RESPONSE_BEGIN"
cat /tmp/atlas-backend-404.body 2>/dev/null || true
echo
echo "BACKEND_ATLAS_RESPONSE_END"

printf '\n=== LIVE VITE/BROWSER-ORIGIN PROBE ===\n'
VITE_STATUS="$(
  curl -sS \
    -o /tmp/atlas-vite-404.body \
    -w '%{http_code}' \
    'http://127.0.0.1:5173/atlas/preexecution?project_id=hq&conversation_id=matilda-conversation-hq-1789754980083-t80g6h' \
    2>/dev/null || true
)"
echo "VITE_ATLAS_HTTP_STATUS=${VITE_STATUS:-000}"
echo "VITE_ATLAS_RESPONSE_BEGIN"
cat /tmp/atlas-vite-404.body 2>/dev/null || true
echo
echo "VITE_ATLAS_RESPONSE_END"

printf '\n=== EXACT FAILURE CLASS ===\n'
if [ "$BACKEND_STATUS" = "200" ] && [ "$VITE_STATUS" = "404" ]; then
  echo "EXACT_FAILURE_CLASS=VITE_ATLAS_PROXY_ROUTE_MISSING"
  echo "NEXT_ACTION=RECONCILE_ATLAS_ROUTE_WITH_BROWSER_ORIGIN_PROXY"
elif [ "$BACKEND_STATUS" = "404" ]; then
  echo "EXACT_FAILURE_CLASS=BACKEND_ATLAS_ROUTE_NOT_MOUNTED_IN_RUNNING_RUNTIME"
  echo "NEXT_ACTION=RECONCILE_RUNNING_SERVER_BUILD_WITH_ATLAS_ROUTE_MOUNT"
elif [ "$BACKEND_STATUS" = "000" ]; then
  echo "EXACT_FAILURE_CLASS=BACKEND_RUNTIME_UNAVAILABLE"
  echo "NEXT_ACTION=RESTORE_PERSISTENT_BACKEND_THEN_REPROBE"
elif [ "$BACKEND_STATUS" = "200" ] && [ "$VITE_STATUS" = "200" ]; then
  echo "EXACT_FAILURE_CLASS=HTTP_PATH_CURRENTLY_HEALTHY_BROWSER_STATE_REQUIRES_RECHECK"
  echo "NEXT_ACTION=REFRESH_BROWSER_AND_VERIFY_ACTIVE_CONVERSATION_REQUEST"
else
  echo "EXACT_FAILURE_CLASS=OTHER_EXACT_HTTP_BOUNDARY_FAILURE"
  echo "NEXT_ACTION=DIAGNOSE_ONLY_THE_STATUS_AND_RESPONSE_CAPTURED_ABOVE"
fi

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  server/index.ts \
  server/routes/atlas/preexecution.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/vite.config.ts

printf '\n=== STOP ===\n'
echo "ATLAS_PERSISTENCE_CORRIDOR_REOPENED=NO"
echo "ATLAS_BROWSER_PRESENTATION_DIAGNOSTIC=ACTIVE"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CLEAR_STOPPING_POINT=YES"
