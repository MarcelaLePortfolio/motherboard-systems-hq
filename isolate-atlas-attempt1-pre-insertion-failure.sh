#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP="server/.atlas-pre-insertion-milestone.test.ts"
LOG="/tmp/atlas-pre-insertion-milestone.log"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -n "$(git diff --name-only -- "$TEST")"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"

printf '\n=== PRESERVE FAILURE CLASSIFICATION ===\n'
echo "READER_ISOLATION_OUTPUT_EMITTED=NO"
echo "FAILURE_PRECEDES_INSERTED_READER_PROBES=YES"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

printf '\n=== LOCATE EXECUTION SEAMS ===\n'
grep -n -E \
  'process\.chdir|conversationRuntime|interpretationRuntime|workflowRuntime|runMatildaConversationWorkflow|beforeTargetEntries|historicalRecords|readAtlasTypedPreexecutionObservations' \
  "$TEST" || true

printf '\n=== CREATE TEMPORARY MILESTONE DIAGNOSTIC ===\n'
rm -f "$TMP" "$LOG"
cp "$TEST" "$TMP"

cleanup() {
  rm -f "$TMP"
}
trap cleanup EXIT

python3 - <<'PY'
from pathlib import Path

path = Path("server/.atlas-pre-insertion-milestone.test.ts")
text = path.read_text()

def inject_before(anchor: str, marker: str) -> None:
    global text
    if text.count(anchor) != 1:
        raise SystemExit(
            f"FAIL CLOSED: expected exactly one milestone anchor: {anchor!r}"
        )
    text = text.replace(
        anchor,
        f'console.error("ATLAS_MILESTONE={marker}");\n\n      {anchor}',
        1,
    )

chdir = "process.chdir(temporaryRoot);"
if text.count(chdir) != 1:
    raise SystemExit("FAIL CLOSED: chdir seam mismatch")
text = text.replace(
    chdir,
    chdir + '\n      console.error("ATLAS_MILESTONE=AFTER_CHDIR");',
    1,
)

for anchor, marker in [
    ("const conversationRuntime =", "BEFORE_CONVERSATION_RUNTIME"),
    ("const interpretationRuntime =", "BEFORE_INTERPRETATION_RUNTIME"),
    ("const workflowRuntime =", "BEFORE_WORKFLOW_RUNTIME"),
    ("const activeConversation =", "BEFORE_ACTIVE_CONVERSATION"),
    ("const beforeTargetEntries =", "BEFORE_INITIAL_IEL_READ"),
]:
    if anchor in text:
        inject_before(anchor, marker)

workflow = "await workflowRuntime.runMatildaConversationWorkflow("
if workflow in text:
    inject_before(workflow, "BEFORE_WORKFLOW_RUN")

historical = "const historicalRecords ="
if historical in text:
    inject_before(historical, "BEFORE_HISTORICAL_ASSERTIONS")

path.write_text(text)
PY

printf '\n=== RUN TEMPORARY MILESTONE DIAGNOSTIC ===\n'
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

printf '\n=== SQLITE EVIDENCE ===\n'
grep -n -B10 -A20 -E \
  'SQLITE_ERROR|no such table|no such column|ATLAS_MILESTONE=' \
  "$LOG" || true

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
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=CLASSIFY_SQLITE_FAILURE_FROM_LAST_REACHED_MILESTONE"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
