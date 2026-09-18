#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP="server/.atlas-post-iel-next-seam.test.ts"
LOG="/tmp/atlas-post-iel-next-seam.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf '\n=== PRESERVE CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "INITIAL_IEL_READ=PASS"
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

path = Path("server/.atlas-post-iel-next-seam.test.ts")
text = path.read_text()

markers = [
    (
        """      const beforeTargetTurns =
        conversationRuntime""",
        """      console.error("ATLAS_MILESTONE=BEFORE_TARGET_TURNS_READ");

      const beforeTargetTurns =
        conversationRuntime""",
    ),
    (
        """      assert.equal(
        beforeTargetEntries.length,""",
        """      console.error("ATLAS_MILESTONE=AFTER_TARGET_TURNS_READ");

      assert.equal(
        beforeTargetEntries.length,""",
    ),
    (
        """      database = new Database(""",
        """      console.error("ATLAS_MILESTONE=BEFORE_EXPLICIT_DATABASE_OPEN");

      database = new Database(""",
    ),
    (
        """      const backfillConversation =""",
        """      console.error("ATLAS_MILESTONE=AFTER_EXPLICIT_DATABASE_OPEN");

      const backfillConversation =""",
    ),
    (
        """      const insertLedger =""",
        """      console.error("ATLAS_MILESTONE=BEFORE_BACKFILL_INSERT_PREPARE");

      const insertLedger =""",
    ),
]

for old, new in markers:
    if text.count(old) != 1:
        raise SystemExit(f"FAIL CLOSED: seam mismatch for {old!r}")
    text = text.replace(old, new, 1)

path.write_text(text)
PY

printf '\n=== RUN NEXT-SEAM DIAGNOSTIC ===\n'
set +e
npx tsx --test --test-reporter=spec "$TMP" >"$LOG" 2>&1
STATUS=$?
set -e

printf 'STATUS=%s\n' "$STATUS"
cat "$LOG"

printf '\n=== REACHED MILESTONES ===\n'
grep 'ATLAS_MILESTONE=' "$LOG" || true

printf '\n=== LAST REACHED MILESTONE ===\n'
grep 'ATLAS_MILESTONE=' "$LOG" | tail -1 || true

printf '\n=== SQLITE FAILURE ===\n'
grep -n -B10 -A20 -E \
  'SQLITE_ERROR|no such table|no such column|database is locked|unable to open database|ATLAS_MILESTONE=' \
  "$LOG" || true

printf '\n=== CLASSIFICATION ===\n'
LAST="$(
  grep 'ATLAS_MILESTONE=' "$LOG" |
    tail -1 |
    sed 's/.*ATLAS_MILESTONE=//' || true
)"

printf 'LAST_MILESTONE=%s\n' "$LAST"

case "$LAST" in
  BEFORE_TARGET_TURNS_READ)
    echo "FAILURE_CLASS=TARGET_TURNS_READ"
    echo "NEXT_ACTION=INSPECT_CONVERSATION_TURN_READ_SCHEMA_ONLY"
    ;;
  AFTER_TARGET_TURNS_READ)
    echo "FAILURE_CLASS=BETWEEN_TARGET_TURNS_AND_DATABASE_OPEN"
    echo "NEXT_ACTION=INSPECT_ASSERTION_AND_DATABASE_OPEN_SEAM_ONLY"
    ;;
  BEFORE_EXPLICIT_DATABASE_OPEN)
    echo "FAILURE_CLASS=EXPLICIT_DATABASE_OPEN"
    echo "NEXT_ACTION=CAPTURE_DATABASE_OPEN_EXCEPTION_ONLY"
    ;;
  AFTER_EXPLICIT_DATABASE_OPEN)
    echo "FAILURE_CLASS=POST_DATABASE_OPEN_PRE_BACKFILL"
    echo "NEXT_ACTION=INSPECT_BACKFILL_CONVERSATION_CREATION_ONLY"
    ;;
  BEFORE_BACKFILL_INSERT_PREPARE)
    echo "FAILURE_CLASS=BACKFILL_INSERT_PREPARE_OR_LATER"
    echo "NEXT_ACTION=CAPTURE_PREPARE_EXCEPTION_ONLY"
    ;;
  *)
    echo "FAILURE_CLASS=UNRESOLVED"
    echo "NEXT_ACTION=STOP_AND_REASSESS_WITHOUT_ATTEMPT_2"
    ;;
esac

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
