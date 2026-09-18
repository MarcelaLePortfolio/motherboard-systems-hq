#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP="server/.atlas-backfill-prepare-exact-anchor.test.ts"
LOG="/tmp/atlas-backfill-prepare-exact-anchor.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE CLASSIFICATION ===\n'
echo "PREVIOUS_DIAGNOSTIC_FAILURE=ANCHOR_MISMATCH_ONLY"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
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

path = Path("server/.atlas-backfill-prepare-exact-anchor.test.ts")
text = path.read_text()

old_prepare = """      const insertLedger =
        database.prepare(`
          INSERT INTO matilda_interpretation_evidence_ledger (
            entry_id,
            created_at,
            actor,
            project_id,
            conversation_id,
            interpretation_event,
            minimum_sufficient_context,
            supporting_raw_evidence,
            matilda_observation,
            unresolved_questions,
            lineage_references,
            supersession_status
          ) VALUES (
            ?,
            ?,
            'matilda',
            'hq',
            ?,
            'Backfill regression fixture',
            'fixture',
            ?,
            ?,
            NULL,
            NULL,
            ?
          )
        `);
"""

new_prepare = """      console.error("ATLAS_MILESTONE=BEFORE_INSERT_LEDGER_PREPARE");

      let insertLedger;
      try {
        insertLedger =
          database.prepare(`
            INSERT INTO matilda_interpretation_evidence_ledger (
              entry_id,
              created_at,
              actor,
              project_id,
              conversation_id,
              interpretation_event,
              minimum_sufficient_context,
              supporting_raw_evidence,
              matilda_observation,
              unresolved_questions,
              lineage_references,
              supersession_status
            ) VALUES (
              ?,
              ?,
              'matilda',
              'hq',
              ?,
              'Backfill regression fixture',
              'fixture',
              ?,
              ?,
              NULL,
              NULL,
              ?
            )
          `);
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
        throw error;
      }
"""

if text.count(old_prepare) != 1:
    raise SystemExit(
        "FAIL CLOSED: exact insertLedger prepare block did not match once"
    )

text = text.replace(old_prepare, new_prepare, 1)

old_run = """        insertLedger.run(
          entryId,
          createdAt,
          backfillConversation.conversation_id,
          supportPayload,
          `Backfill interpretation ${suffix}`,
          isRecentIneligible
            ? "superseded"
            : "current",
        );
"""

new_run = """        console.error(
          "ATLAS_MILESTONE=BEFORE_INSERT_LEDGER_RUN_" + suffix,
        );

        try {
          insertLedger.run(
            entryId,
            createdAt,
            backfillConversation.conversation_id,
            supportPayload,
            `Backfill interpretation ${suffix}`,
            isRecentIneligible
              ? "superseded"
              : "current",
          );
          console.error(
            "ATLAS_MILESTONE=AFTER_INSERT_LEDGER_RUN_" + suffix,
          );
        } catch (error) {
          console.error("BACKFILL_RUN_RESULT=FAILURE");
          console.error("BACKFILL_RUN_SUFFIX=" + suffix);
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
          throw error;
        }
"""

if text.count(old_run) != 1:
    raise SystemExit(
        "FAIL CLOSED: exact insertLedger run block did not match once"
    )

text = text.replace(old_run, new_run, 1)
path.write_text(text)
PY

printf '\n=== RUN EXACT BACKFILL PROBE ===\n'
set +e
npx tsx --test --test-reporter=spec "$TMP" >"$LOG" 2>&1
STATUS=$?
set -e

printf 'STATUS=%s\n' "$STATUS"
cat "$LOG"

printf '\n=== EXACT BACKFILL EVIDENCE ===\n'
grep -E \
  'ATLAS_MILESTONE=BEFORE_INSERT_LEDGER|ATLAS_MILESTONE=AFTER_INSERT_LEDGER|BACKFILL_PREPARE_|BACKFILL_RUN_' \
  "$LOG" || true

printf '\n=== CLASSIFICATION ===\n'
if grep -q 'BACKFILL_PREPARE_RESULT=FAILURE' "$LOG"; then
  echo "FAILURE_CLASS=BACKFILL_SQL_PREPARE"
  echo "NEXT_ACTION=USE_EXACT_PREPARE_ERROR_TO_DEFINE_ATTEMPT_2"
elif grep -q 'BACKFILL_RUN_RESULT=FAILURE' "$LOG"; then
  echo "FAILURE_CLASS=BACKFILL_SQL_RUN"
  echo "NEXT_ACTION=USE_EXACT_RUN_ERROR_TO_DEFINE_ATTEMPT_2"
elif grep -q 'ATLAS_MILESTONE=AFTER_INSERT_LEDGER_RUN_040' "$LOG"; then
  echo "BACKFILL_LEDGER_INSERTS=PASS"
  echo "FAILURE_CLASS=AFTER_BACKFILL_LEDGER_INSERT"
  echo "NEXT_ACTION=ISOLATE_NEXT_POST_LEDGER_SEAM"
else
  echo "FAILURE_CLASS=UNRESOLVED"
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
