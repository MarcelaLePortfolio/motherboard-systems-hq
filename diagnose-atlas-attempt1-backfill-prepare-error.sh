#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP="server/.atlas-backfill-prepare-error.test.ts"
LOG="/tmp/atlas-backfill-prepare-error.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "INITIAL_IEL_READ=PASS"
echo "TARGET_TURNS_READ=PASS"
echo "EXPLICIT_DATABASE_OPEN=PASS"
echo "FAILURE_BOUNDARY=BACKFILL_INSERT_PREPARE_OR_IMMEDIATELY_AFTER"
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

path = Path("server/.atlas-backfill-prepare-error.test.ts")
text = path.read_text()

start = """      const insertLedger =
        database.prepare(`"""

if text.count(start) != 1:
    raise SystemExit("FAIL CLOSED: expected exactly one insertLedger prepare seam")

text = text.replace(
    start,
    """      console.error("ATLAS_MILESTONE=BEFORE_INSERT_LEDGER_PREPARE");

      let insertLedger;
      try {
        insertLedger =
          database.prepare(`""",
    1,
)

end = """      `);

      insertLedger.run("""

if text.count(end) != 1:
    raise SystemExit("FAIL CLOSED: expected exactly one insertLedger prepare terminator")

text = text.replace(
    end,
    """      `);
        console.error("ATLAS_MILESTONE=AFTER_INSERT_LEDGER_PREPARE");
      } catch (error) {
        console.error("BACKFILL_PREPARE_RESULT=FAILURE");
        console.error(
          "BACKFILL_PREPARE_ERROR_NAME=" +
            (error instanceof Error ? error.name : typeof error),
        );
        console.error(
          "BACKFILL_PREPARE_ERROR_MESSAGE=" +
            (error instanceof Error ? error.message : String(error)),
        );
        console.error(
          "BACKFILL_PREPARE_ERROR_CODE=" +
            String(
              error &&
              typeof error === "object" &&
              "code" in error
                ? error.code
                : "",
            ),
        );
        console.error(
          "BACKFILL_PREPARE_ERROR_STACK=" +
            (error instanceof Error ? error.stack : String(error)),
        );
        throw error;
      }

      console.error("ATLAS_MILESTONE=BEFORE_INSERT_LEDGER_RUN");

      try {
        insertLedger.run(""",
    1,
)

run_end = """      );

      const backfillEntry ="""

if text.count(run_end) != 1:
    raise SystemExit("FAIL CLOSED: expected exactly one insertLedger run terminator")

text = text.replace(
    run_end,
    """      );
        console.error("ATLAS_MILESTONE=AFTER_INSERT_LEDGER_RUN");
      } catch (error) {
        console.error("BACKFILL_RUN_RESULT=FAILURE");
        console.error(
          "BACKFILL_RUN_ERROR_NAME=" +
            (error instanceof Error ? error.name : typeof error),
        );
        console.error(
          "BACKFILL_RUN_ERROR_MESSAGE=" +
            (error instanceof Error ? error.message : String(error)),
        );
        console.error(
          "BACKFILL_RUN_ERROR_CODE=" +
            String(
              error &&
              typeof error === "object" &&
              "code" in error
                ? error.code
                : "",
            ),
        );
        console.error(
          "BACKFILL_RUN_ERROR_STACK=" +
            (error instanceof Error ? error.stack : String(error)),
        );
        throw error;
      }

      const backfillEntry =""",
    1,
)

path.write_text(text)
PY

printf '\n=== RUN EXACT BACKFILL DIAGNOSTIC ===\n'
set +e
npx tsx --test --test-reporter=spec "$TMP" >"$LOG" 2>&1
STATUS=$?
set -e

printf 'STATUS=%s\n' "$STATUS"
cat "$LOG"

printf '\n=== MILESTONES ===\n'
grep 'ATLAS_MILESTONE=' "$LOG" || true

printf '\n=== EXACT BACKFILL ERROR ===\n'
grep -E \
  'BACKFILL_PREPARE_RESULT=|BACKFILL_PREPARE_ERROR_|BACKFILL_RUN_RESULT=|BACKFILL_RUN_ERROR_' \
  "$LOG" || true

printf '\n=== CLASSIFICATION ===\n'
if grep -q 'BACKFILL_PREPARE_RESULT=FAILURE' "$LOG"; then
  echo "FAILURE_CLASS=BACKFILL_SQL_PREPARE"
  echo "NEXT_ACTION=CLASSIFY_EXACT_PREPARE_SQL_ERROR_BEFORE_ATTEMPT_2"
elif grep -q 'BACKFILL_RUN_RESULT=FAILURE' "$LOG"; then
  echo "FAILURE_CLASS=BACKFILL_SQL_RUN"
  echo "NEXT_ACTION=CLASSIFY_EXACT_INSERT_BINDING_OR_SCHEMA_ERROR_BEFORE_ATTEMPT_2"
elif grep -q 'ATLAS_MILESTONE=AFTER_INSERT_LEDGER_RUN' "$LOG"; then
  echo "FAILURE_CLASS=AFTER_BACKFILL_INSERT"
  echo "NEXT_ACTION=ISOLATE_NEXT_POST_BACKFILL_STEP"
else
  echo "FAILURE_CLASS=UNRESOLVED_WITHIN_BACKFILL_PROBE"
  echo "NEXT_ACTION=STOP_AND_REASSESS_WITHOUT_ATTEMPT_2"
fi

rm -f "$TMP"
trap - EXIT
test ! -e "$TMP"

printf '\n=== VERIFY AUTHORIZED TEST PRESERVED ===\n'
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
