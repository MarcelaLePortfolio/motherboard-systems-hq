#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE FAILURE STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "ASSERTION_WEAKENING=PROHIBITED"
echo "PRODUCT_MUTATION=NO"

PROBE="server/.atlas-attempt2-require-cache-probe.test.ts"

cat > "$PROBE" <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  readAtlasHistoricalObservations,
} from "../db/atlas-historical-observation-persistence";
import {
  readAtlasHistoricalTypedObservations,
} from "./atlas/atlas-historical-observation-adapter";
import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";

void readAtlasHistoricalObservations;
void readAtlasHistoricalTypedObservations;
void readAtlasTypedPreexecutionObservations;

test("classifies Atlas top-level import preload", () => {
  const cacheKeys = Object.keys(require.cache);

  const matches = cacheKeys.filter((key) =>
    key.endsWith("/scripts/utils/ollamaChat.ts")
    || key.endsWith("/server/matilda-chat-workflow.ts")
    || key.endsWith("/db/matilda-interpretation-runtime.ts")
    || key.endsWith("/db/matilda-conversation-runtime.ts")
  );

  console.log("PRELOAD_MATCHES_BEGIN");
  for (const match of matches.sort()) {
    console.log(match);
  }
  console.log("PRELOAD_MATCHES_END");

  const ollamaPreloaded = matches.some((key) =>
    key.endsWith("/scripts/utils/ollamaChat.ts")
  );

  const workflowPreloaded = matches.some((key) =>
    key.endsWith("/server/matilda-chat-workflow.ts")
  );

  const interpretationRuntimePreloaded =
    matches.some((key) =>
      key.endsWith("/db/matilda-interpretation-runtime.ts")
    );

  const conversationRuntimePreloaded =
    matches.some((key) =>
      key.endsWith("/db/matilda-conversation-runtime.ts")
    );

  console.log(
    `OLLAMA_PRELOADED_BEFORE_FIXTURE_ENV=${ollamaPreloaded ? "YES" : "NO"}`,
  );
  console.log(
    `WORKFLOW_PRELOADED_BEFORE_FIXTURE_ENV=${workflowPreloaded ? "YES" : "NO"}`,
  );
  console.log(
    `INTERPRETATION_RUNTIME_PRELOADED=${interpretationRuntimePreloaded ? "YES" : "NO"}`,
  );
  console.log(
    `CONVERSATION_RUNTIME_PRELOADED=${conversationRuntimePreloaded ? "YES" : "NO"}`,
  );

  if (ollamaPreloaded) {
    console.log(
      "ROOT_CAUSE_CLASS=TOP_LEVEL_ATLAS_IMPORT_PRELOADS_OLLAMA_BEFORE_FIXTURE_ENV",
    );
  } else if (interpretationRuntimePreloaded) {
    console.log(
      "ROOT_CAUSE_CLASS=TOP_LEVEL_ATLAS_IMPORT_PRELOADS_INTERPRETATION_RUNTIME_ONLY",
    );
  } else {
    console.log(
      "ROOT_CAUSE_CLASS=TOP_LEVEL_ATLAS_IMPORT_PRELOAD_NOT_PROVEN",
    );
  }

  assert.ok(true);
});
TS

printf '\n=== RUN ISOLATED PRELOAD PROBE ===\n'
set +e
npx tsx --test "$PROBE"
PROBE_STATUS=$?
set -e
printf 'PROBE_STATUS=%s\n' "$PROBE_STATUS"

printf '\n=== CLEAN DIAGNOSTIC PROBE ===\n'
rm -f "$PROBE"

printf '\n=== VERIFY AUTHORIZED TEST UNCHANGED BY PROBE ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_REQUIRE_CACHE_PRELOAD_RESULT"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
