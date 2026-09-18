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

printf '\n=== PROVEN ROOT CAUSE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=2"
echo "OLLAMA_PRELOADED_BEFORE_FIXTURE_ENV=YES"
echo "INTERPRETATION_RUNTIME_PRELOADED_BEFORE_FIXTURE_CHDIR=YES"
echo "WORKFLOW_PRELOADED_BEFORE_FIXTURE_ENV=NO"
echo "ROOT_CAUSE=NEW_TOP_LEVEL_ATLAS_IMPORTS_PRELOAD_RUNTIME_DEPENDENCIES"
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"

printf '\n=== EXACT CURRENT TOP-LEVEL ATLAS IMPORTS ===\n'
nl -ba "$TEST" | sed -n '1,32p'

printf '\n=== EXACT FIXTURE-LOCAL REQUIRE SEAM ===\n'
nl -ba "$TEST" | sed -n '183,220p'

printf '\n=== PROPOSED ATTEMPT 3 ===\n'
cat <<'PLAN'
AUTHORIZED_PATH_ONLY=server/matilda-chat-workflow.explicit-target.integration.test.ts

REMOVE_TOP_LEVEL_IMPORTS:
- ../db/atlas-historical-observation-persistence
- ./atlas/atlas-historical-observation-adapter
- ./atlas/atlas-preexecution-observation-aggregator

ADD_FIXTURE_LOCAL_REQUIRES_AFTER:
1. process.env.OLLAMA_BASE_URL is assigned
2. process.chdir(temporaryRoot) has executed
3. alongside the existing fixture-local conversation/interpretation/workflow requires

KEEP_UNCHANGED:
- temporary IEL schema initialization added in Attempt 2
- pre-existing exactly-one-Ollama assertion
- all behavioral assertions
- all product/runtime files
- all authority boundaries

EXPECTED_EFFECT:
- ollamaChat.ts first loads after fixture OLLAMA_BASE_URL is set
- matilda-interpretation-runtime.ts first loads after fixture chdir
- workflow and Atlas readers observe the same temporary runtime context
- no assertion weakening or product mutation
PLAN

printf '\n=== VERIFY CURRENT PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-conversation-runtime.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== AUTHORIZATION GATE ===\n'
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "ATTEMPT_3_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo
echo "REPLY EXACTLY:"
echo "Authorize Atlas lifecycle test Attempt 3 to move only the three newly added Atlas reader imports in server/matilda-chat-workflow.explicit-target.integration.test.ts into the existing fixture-local require sequence after OLLAMA_BASE_URL is set and process.chdir(temporaryRoot), preserving the Attempt 2 temporary IEL schema initialization and all existing assertions, with no product-code changes, live dogfood execution, production database mutation, destructive cleanup, scheduling, routing, orchestration, authority changes, test commit, or push."
