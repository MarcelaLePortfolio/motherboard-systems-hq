#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP="server/.atlas-iel-exact-error.test.ts"
LOG="/tmp/atlas-iel-exact-error.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "STATIC_IEL_SCHEMA_CHECK=PASS"
echo "FAILURE_LOCATION=INITIAL_IEL_READ"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

rm -f "$TMP" "$LOG"
cp "$TEST" "$TMP"

cleanup() {
  rm -f "$TMP"
}
trap cleanup EXIT

python3 - <<'PY'
from pathlib import Path

path = Path("server/.atlas-iel-exact-error.test.ts")
text = path.read_text()

anchor = """      const beforeTargetEntries =
        interpretationRuntime
          .listInterpretationEvidenceLedgerEntries(
            100,
            {
              projectId: "hq",
              conversationId:
                explicitTargetConversation
                  .conversation_id,
            },
          );"""

if text.count(anchor) != 1:
    raise SystemExit(
        "FAIL CLOSED: expected exactly one initial IEL read anchor"
    )

replacement = """      let beforeTargetEntries;
      try {
        beforeTargetEntries =
          interpretationRuntime
            .listInterpretationEvidenceLedgerEntries(
              100,
              {
                projectId: "hq",
                conversationId:
                  explicitTargetConversation
                    .conversation_id,
              },
            );
        console.error("IEL_INITIAL_READ_RESULT=SUCCESS");
      } catch (error) {
        console.error("IEL_INITIAL_READ_RESULT=FAILURE");
        console.error(
          "IEL_ERROR_NAME=" +
            (error instanceof Error ? error.name : typeof error),
        );
        console.error(
          "IEL_ERROR_MESSAGE=" +
            (error instanceof Error ? error.message : String(error)),
        );
        console.error(
          "IEL_ERROR_CODE=" +
            String(
              error &&
              typeof error === "object" &&
              "code" in error
                ? error.code
                : "",
            ),
        );
        console.error(
          "IEL_ERROR_STACK=" +
            (error instanceof Error ? error.stack : String(error)),
        );
        throw error;
      }"""

text = text.replace(anchor, replacement, 1)
path.write_text(text)
PY

printf '\n=== RUN EXACT ERROR DIAGNOSTIC ===\n'
set +e
npx tsx --test --test-reporter=spec "$TMP" >"$LOG" 2>&1
STATUS=$?
set -e

printf 'STATUS=%s\n' "$STATUS"
cat "$LOG"

printf '\n=== EXACT IEL ERROR ===\n'
grep -E \
  'IEL_INITIAL_READ_RESULT=|IEL_ERROR_NAME=|IEL_ERROR_MESSAGE=|IEL_ERROR_CODE=' \
  "$LOG" || true

printf '\n=== SQLITE FAILURE TEXT ===\n'
grep -n -B5 -A15 -E \
  'IEL_ERROR_MESSAGE=|SQLITE_ERROR|no such table|no such column|database is locked|unable to open database|has no column named' \
  "$LOG" || true

printf '\n=== CLASSIFY ===\n'
if grep -q 'IEL_INITIAL_READ_RESULT=SUCCESS' "$LOG"; then
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=NO"
  echo "NEXT_ACTION=ISOLATE_FAILURE_IMMEDIATELY_AFTER_INITIAL_IEL_READ"
elif grep -q 'no such column' "$LOG"; then
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=YES"
  echo "FAILURE_CLASS=IEL_SCHEMA_COLUMN_MISMATCH"
  echo "NEXT_ACTION=IDENTIFY_EXACT_MISSING_COLUMN_AND_INITIALIZATION_CAUSE"
elif grep -q 'no such table' "$LOG"; then
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=YES"
  echo "FAILURE_CLASS=IEL_TABLE_INITIALIZATION_MISMATCH"
  echo "NEXT_ACTION=IDENTIFY_DATABASE_BINDING_AND_TABLE_INITIALIZATION_CAUSE"
elif grep -q 'database is locked' "$LOG"; then
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=YES"
  echo "FAILURE_CLASS=SQLITE_LOCKING"
  echo "NEXT_ACTION=IDENTIFY_CONNECTION_OWNERSHIP_AND_LOCK_SOURCE"
elif grep -q 'unable to open database' "$LOG"; then
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=YES"
  echo "FAILURE_CLASS=SQLITE_DATABASE_PATH"
  echo "NEXT_ACTION=IDENTIFY_RELATIVE_DATABASE_BINDING"
else
  echo "IEL_READER_DIRECT_FAILURE_REPRODUCED=YES"
  echo "FAILURE_CLASS=SQLITE_EXACT_ERROR_CAPTURED_ABOVE"
  echo "NEXT_ACTION=CLASSIFY_CAPTURED_SQLITE_ERROR_BEFORE_ATTEMPT_2"
fi

printf '\n=== REMOVE TEMPORARY DIAGNOSTIC ===\n'
rm -f "$TMP"
trap - EXIT
test ! -e "$TMP"

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT BOUNDARIES ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== STOP ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
