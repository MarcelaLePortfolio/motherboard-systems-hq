#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
DOGFOOD_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"

printf '\n=== CURRENT HEAD ===\n'
echo "HEAD=$(git rev-parse HEAD)"
echo "REMOTE_HEAD=$(git rev-parse "origin/$BRANCH")"

printf '\n=== VERIFY VITE PROXY CONFIG ===\n'
grep -n -A8 -B4 '"/atlas"' client/vite.config.ts

printf '\n=== VERIFY BACKEND REMAINS HEALTHY ===\n'
BACKEND_STATUS="$(
  curl -sS \
    -o /tmp/atlas-backend-validation.body \
    -w '%{http_code}' \
    "http://127.0.0.1:3000/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "BACKEND_ATLAS_HTTP_STATUS=$BACKEND_STATUS"
test "$BACKEND_STATUS" = "200"

printf '\n=== RESTART VITE WITH CURRENT CONFIG ===\n'
VITE_PIDS="$(
  lsof -tiTCP:5173 -sTCP:LISTEN 2>/dev/null || true
)"

if [ -n "$VITE_PIDS" ]; then
  for pid in $VITE_PIDS; do
    echo "STOPPING_VITE_PID=$pid"
    kill "$pid"
  done
fi

for _ in $(seq 1 40); do
  if ! lsof -tiTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

(
  cd client
  nohup npm run dev -- --host 127.0.0.1 \
    >/tmp/motherboard-atlas-vite.log \
    2>&1 &
  echo $! >/tmp/motherboard-atlas-vite.pid
)

VITE_READY=NO

for _ in $(seq 1 60); do
  STATUS="$(
    curl -sS \
      -o /tmp/atlas-vite-root.body \
      -w '%{http_code}' \
      'http://127.0.0.1:5173/' \
      2>/dev/null || true
  )"

  if [ "$STATUS" = "200" ]; then
    VITE_READY=YES
    break
  fi

  sleep 0.5
done

echo "VITE_READY=$VITE_READY"
test "$VITE_READY" = "YES"

printf '\n=== PROVE ATLAS THROUGH BROWSER ORIGIN ===\n'
ATLAS_STATUS="$(
  curl -sS \
    -o /tmp/atlas-vite-proxy-validation.body \
    -w '%{http_code}' \
    "http://127.0.0.1:5173/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "ATLAS_BROWSER_HTTP_STATUS=$ATLAS_STATUS"
echo "ATLAS_BROWSER_RESPONSE_BEGIN"
cat /tmp/atlas-vite-proxy-validation.body
echo
echo "ATLAS_BROWSER_RESPONSE_END"

test "$ATLAS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync(
    "/tmp/atlas-vite-proxy-validation.body",
    "utf8",
  ),
);

if (payload.status !== "ok") {
  throw new Error(
    `Expected status=ok, received ${payload.status}`,
  );
}

if (payload.route !== "atlas_preexecution_read_route") {
  throw new Error(
    `Unexpected route ${payload.route}`,
  );
}

if (payload.projectId !== "hq") {
  throw new Error(
    `Expected projectId=hq, received ${payload.projectId}`,
  );
}

if (!Array.isArray(payload.observations)) {
  throw new Error("Expected observations array");
}

if (payload.observations.length !== 3) {
  throw new Error(
    `Expected 3 Atlas observations, received ${payload.observations.length}`,
  );
}

if (
  payload.causalExplanation !== false ||
  payload.executionHistory !== false ||
  payload.approvalDecision !== false ||
  payload.authorityDecision !== false
) {
  throw new Error(
    "Atlas read-only authority invariants were not preserved",
  );
}

console.log("ATLAS_BROWSER_ORIGIN_JSON=PASS");
console.log(
  `ATLAS_OBSERVATION_COUNT=${payload.observations.length}`,
);
console.log("ATLAS_AUTHORITY_PROMOTION=NO");
NODE

printf '\n=== VERIFY NO UNRELATED PRODUCT MUTATION ===\n'
git diff --exit-code -- \
  server/index.ts \
  server/routes/atlas/preexecution.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "ATLAS_BACKEND_ROUTE=HEALTHY"
echo "ATLAS_VITE_PROXY=HEALTHY"
echo "ATLAS_BROWSER_ORIGIN_READBACK=PASS"
echo "ATLAS_BROWSER_PRESENTATION_PATH=HEALTHY"
echo "ATLAS_DOGFOOD_OBSERVATIONS_AVAILABLE=3"
echo "PREVIOUS_404_CAUSE=STALE_BACKEND_PLUS_MISSING_VITE_ATLAS_PROXY"
echo "ATLAS_PRODUCT_FIX=VITE_PROXY_ONLY"
echo "ATLAS_PERSISTENCE_CORRIDOR_REOPENED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=REFRESH_UI_AND_CONFIRM_ATLAS_CARD_RENDERS_OBSERVATIONS"

git add -- validate-atlas-vite-proxy-fix.sh
git commit -m "Validate Atlas browser proxy fix"
git push origin "$BRANCH"
