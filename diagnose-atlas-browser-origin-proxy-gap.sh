#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="7bbea91ec13e3c0de357948412157e66326f8d3a"
DOGFOOD_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== VERIFIED BACKEND BASELINE ===\n'
BACKEND_STATUS="$(
  curl -sS \
    -o /tmp/atlas-browser-origin-backend.body \
    -w '%{http_code}' \
    "http://127.0.0.1:3000/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "BACKEND_ATLAS_HTTP_STATUS=$BACKEND_STATUS"
test "$BACKEND_STATUS" = "200"

printf '\n=== VITE CONFIG ===\n'
cat client/vite.config.ts

printf '\n=== CLIENT REQUEST ===\n'
grep -n -A12 -B8 \
  'fetch(`/atlas/preexecution' \
  client/src/atlas/atlasPreexecutionApi.ts

printf '\n=== BROWSER-ORIGIN ATLAS PROBE ===\n'
VITE_STATUS="$(
  curl -sS \
    -o /tmp/atlas-browser-origin-vite.body \
    -w '%{http_code}' \
    "http://127.0.0.1:5173/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "VITE_ATLAS_HTTP_STATUS=$VITE_STATUS"
echo "VITE_ATLAS_CONTENT_TYPE=$(
  curl -sSI \
    "http://127.0.0.1:5173/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null \
    | awk -F': ' 'tolower($1)=="content-type" {gsub(/\r/,"",$2); print $2}' \
    | tail -1
)"

echo "VITE_ATLAS_RESPONSE_BEGIN"
cat /tmp/atlas-browser-origin-vite.body 2>/dev/null || true
echo
echo "VITE_ATLAS_RESPONSE_END"

printf '\n=== RESPONSE CLASSIFICATION ===\n'
node <<'NODE'
const fs = require("fs");

const body = fs.readFileSync(
  "/tmp/atlas-browser-origin-vite.body",
  "utf8",
);

if (
  body.includes('<script type="module" src="/@vite/client">') ||
  body.includes('<div id="root"></div>')
) {
  console.log("VITE_RESPONSE_CLASS=SPA_HTML_FALLBACK");
  console.log("ATLAS_BROWSER_REQUEST_REACHED_BACKEND=NO");
  console.log("ATLAS_BROWSER_PROXY_GAP=PROVEN");
} else {
  try {
    const parsed = JSON.parse(body);

    if (
      parsed.route === "atlas_preexecution_read_route" &&
      parsed.status === "ok"
    ) {
      console.log("VITE_RESPONSE_CLASS=ATLAS_JSON");
      console.log("ATLAS_BROWSER_REQUEST_REACHED_BACKEND=YES");
      console.log("ATLAS_BROWSER_PROXY_GAP=NO");
    } else {
      console.log("VITE_RESPONSE_CLASS=OTHER_JSON");
      console.log("ATLAS_BROWSER_PROXY_GAP=UNRESOLVED");
    }
  } catch {
    console.log("VITE_RESPONSE_CLASS=OTHER_NON_JSON");
    console.log("ATLAS_BROWSER_PROXY_GAP=UNRESOLVED");
  }
}
NODE

printf '\n=== EXACT CONFIGURATION GAP ===\n'
if grep -q '"/api"' client/vite.config.ts \
  && ! grep -q '"/atlas"' client/vite.config.ts; then
  echo "VITE_API_PROXY_PRESENT=YES"
  echo "VITE_ATLAS_PROXY_PRESENT=NO"
else
  echo "VITE_PROXY_CONFIGURATION_REQUIRES_MANUAL_REVIEW=YES"
fi

printf '\n=== NO PRODUCT MUTATION ===\n'
git diff --exit-code -- \
  client/vite.config.ts \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  server/index.ts \
  server/routes/atlas/preexecution.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== STOPPING POINT ===\n'
echo "ATLAS_PERSISTENCE_CORRIDOR_REOPENED=NO"
echo "ATLAS_BACKEND_ROUTE=HEALTHY"
echo "ATLAS_BROWSER_PRESENTATION_DIAGNOSTIC=ACTIVE"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CLEAR_STOPPING_POINT=YES"
