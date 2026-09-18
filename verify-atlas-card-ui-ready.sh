#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="abbb2de8d476ba659481400ecb185690d6b71a9d"
DOGFOOD_CONVERSATION="matilda-conversation-hq-1789754980083-t80g6h"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

ATLAS_STATUS="$(
  curl -sS \
    -o /tmp/atlas-ui-ready.body \
    -w '%{http_code}' \
    "http://127.0.0.1:5173/atlas/preexecution?projectId=hq&conversationId=$DOGFOOD_CONVERSATION" \
    2>/dev/null || true
)"

echo "ATLAS_BROWSER_HTTP_STATUS=$ATLAS_STATUS"
test "$ATLAS_STATUS" = "200"

node <<'NODE'
const fs = require("fs");

const payload = JSON.parse(
  fs.readFileSync("/tmp/atlas-ui-ready.body", "utf8"),
);

if (payload.status !== "ok") {
  throw new Error(`Expected status=ok, received ${payload.status}`);
}

if (!Array.isArray(payload.observations)) {
  throw new Error("Expected observations array");
}

if (payload.observations.length !== 3) {
  throw new Error(
    `Expected 3 observations, received ${payload.observations.length}`,
  );
}

console.log("ATLAS_UI_DATA_PATH=READY");
console.log("ATLAS_OBSERVATION_COUNT=3");
console.log("ATLAS_AUTHORITY_PROMOTION=NO");
console.log("MANUAL_NEXT_STEP=REFRESH_BROWSER_AND_CONFIRM_CARD_RENDER");
NODE

git add -- verify-atlas-card-ui-ready.sh
git commit -m "Verify Atlas card UI data path readiness"
git push origin "$BRANCH"
