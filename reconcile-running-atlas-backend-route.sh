#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="4a35ff8c642e6c8bfebc00acf2d0dbd49d2fc6f8"
DOGFOOD_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

printf '\n=== BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

echo "HEAD=$EXPECTED_HEAD"
echo "ATLAS_PERSISTENCE_CORRIDOR=CLOSED"
echo "ATLAS_BROWSER_PRESENTATION_DIAGNOSTIC=ACTIVE"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

printf '\n=== VERIFY SOURCE ROUTE EXISTS ===\n'
grep -n 'router.get("/atlas/preexecution"' \
  server/routes/atlas/preexecution.ts

grep -n 'app.use(atlasPreExecutionRouter)' \
  server/index.ts

printf '\n=== BUILD CURRENT SERVER ===\n'
npm run build

printf '\n=== IDENTIFY CURRENT BACKEND LISTENER ===\n'
CURRENT_BACKEND_PIDS="$(
  lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null || true
)"

echo "CURRENT_BACKEND_PIDS=${CURRENT_BACKEND_PIDS:-NONE}"

if [ -n "$CURRENT_BACKEND_PIDS" ]; then
  for pid in $CURRENT_BACKEND_PIDS; do
    echo "STOPPING_STALE_BACKEND_PID=$pid"
    kill "$pid"
  done

  for _ in $(seq 1 40); do
    if ! lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
      break
    fi
    sleep 0.25
  done
fi

if lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "ERROR=PORT_3000_STILL_OCCUPIED"
  exit 1
fi

printf '\n=== START CURRENT BACKEND PERSISTENTLY ===\n'
nohup npm start \
  >/tmp/motherboard-atlas-reconciled-backend.log \
  2>&1 &

NEW_BACKEND_PID=$!
echo "$NEW_BACKEND_PID" \
  >/tmp/motherboard-atlas-reconciled-backend.pid

echo "NEW_BACKEND_PID=$NEW_BACKEND_PID"

BACKEND_READY=NO

for _ in $(seq 1 60); do
  STATUS="$(
    curl -sS \
      -o /tmp/atlas-reconciled-registry.body \
      -w '%{http_code}' \
      'http://127.0.0.1:3000/api/projects/registry' \
      2>/dev/null || true
  )"

  if [ "$STATUS" = "200" ]; then
    BACKEND_READY=YES
    break
  fi

  sleep 0.5
done

echo "BACKEND_READY=$BACKEND_READY"
test "$BACKEND_READY" = "YES"

printf '\n=== PROBE ATLAS DIRECTLY ON BACKEND ===\n'
ATLAS_STATUS="$(
  curl -sS \
    -o /tmp/atlas-reconciled-route.body \
    -w '%{http_code}' \
    "http://127.0.0.1:3000/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "ATLAS_BACKEND_HTTP_STATUS=$ATLAS_STATUS"

echo "ATLAS_BACKEND_RESPONSE_BEGIN"
cat /tmp/atlas-reconciled-route.body 2>/dev/null || true
echo
echo "ATLAS_BACKEND_RESPONSE_END"

test "$ATLAS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/atlas-reconciled-route.body",
    "utf8",
  ),
);

if (payload.status !== "ok") {
  throw new Error(
    `Expected Atlas status=ok, received ${payload.status}`,
  );
}

if (payload.projectId !== "hq") {
  throw new Error(
    `Expected Atlas projectId=hq, received ${payload.projectId}`,
  );
}

if (!Array.isArray(payload.observations)) {
  throw new Error("Expected Atlas observations array");
}

if (
  payload.causalExplanation !== false ||
  payload.executionHistory !== false ||
  payload.approvalDecision !== false ||
  payload.authorityDecision !== false
) {
  throw new Error(
    "Atlas authority/read-only invariants were not preserved",
  );
}

console.log(
  `ATLAS_OBSERVATION_COUNT=${payload.observations.length}`,
);
console.log("ATLAS_DIRECT_BACKEND_ROUTE=PASS");
console.log("ATLAS_AUTHORITY_PROMOTION=NO");
NODE

printf '\n=== CLASSIFICATION ===\n'
echo "PREVIOUS_FAILURE_CLASS=STALE_RUNNING_BACKEND_BUILD"
echo "CURRENT_SOURCE_ROUTE_PRESENT=YES"
echo "CURRENT_BACKEND_ROUTE_PRESENT=YES"
echo "PRODUCT_CODE_FIX_REQUIRED=NO"
echo "BACKEND_RUNTIME_RECONCILIATION=PASS"
echo "ATLAS_PERSISTENCE_CORRIDOR_REOPENED=NO"

printf '\n=== VERIFY NO PRODUCT MUTATION ===\n'
git diff --exit-code -- \
  server/index.ts \
  server/routes/atlas/preexecution.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/vite.config.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "NEXT_QUESTION=DOES_BROWSER_ORIGIN_STILL_REQUIRE_ATLAS_PROXY"
echo "DO_NOT_CHANGE_PRODUCT_CODE_YET=YES"
echo "CLEAR_STOPPING_POINT=YES"
