#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"
TMP_TEST="server/.atlas-reader-isolation.test.ts"
LOG="/tmp/atlas-reader-isolation-repo-local.log"

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

printf '\n=== PRESERVE FAILURE COUNT ===\n'
echo "PREVIOUS_DIAGNOSTIC_FAILURE=MODULE_RESOLUTION_ONLY"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

rm -f "$TMP_TEST" "$LOG"
cp "$TEST" "$TMP_TEST"

cleanup() {
  rm -f "$TMP_TEST"
}
trap cleanup EXIT

python3 - <<'PY'
from pathlib import Path

path = Path("server/.atlas-reader-isolation.test.ts")
text = path.read_text()

old = '''import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";
'''

new = '''import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";
import {
  readAtlasPreExecutionObservations,
} from "./atlas/atlas-preexecution-read-model";
import {
  readAtlasLivingDraftObservations,
  readAtlasPendingApprovalObservations,
} from "./atlas/atlas-draft-approval-observation";
import {
  readAtlasCanonicalPackageObservations,
} from "./atlas/atlas-canonical-package-observation";
'''

if text.count(old) != 1:
    raise SystemExit("FAIL CLOSED: import seam mismatch")

text = text.replace(old, new, 1)

anchor = '''      const merged =
        readAtlasTypedPreexecutionObservations({
'''

diagnostic = '''      const isolatedReaderResults: Array<{
        reader: string;
        status: "pass" | "fail";
        error: string | null;
      }> = [];

      const captureReader = (
        reader: string,
        fn: () => unknown,
      ): void => {
        try {
          fn();
          isolatedReaderResults.push({
            reader,
            status: "pass",
            error: null,
          });
        } catch (error) {
          const candidate = error as {
            name?: unknown;
            message?: unknown;
            code?: unknown;
          };

          isolatedReaderResults.push({
            reader,
            status: "fail",
            error: JSON.stringify({
              name:
                typeof candidate?.name === "string"
                  ? candidate.name
                  : null,
              message:
                typeof candidate?.message === "string"
                  ? candidate.message
                  : String(error),
              code:
                typeof candidate?.code === "string"
                  ? candidate.code
                  : null,
            }),
          });
        }
      };

      captureReader(
        "interpretation_evidence",
        () =>
          readAtlasPreExecutionObservations({
            projectId: "hq",
            conversationId:
              explicitTargetConversation.conversation_id,
          }),
      );

      captureReader(
        "living_draft",
        () =>
          readAtlasLivingDraftObservations(
            "hq",
            databasePath,
          ),
      );

      captureReader(
        "pending_approval",
        () =>
          readAtlasPendingApprovalObservations(
            "hq",
            databasePath,
          ),
      );

      captureReader(
        "canonical_package",
        () =>
          readAtlasCanonicalPackageObservations(
            "hq",
            databasePath,
          ),
      );

      console.error(
        "ATLAS_READER_ISOLATION_RESULTS=" +
          JSON.stringify(isolatedReaderResults),
      );

'''

if text.count(anchor) != 1:
    raise SystemExit("FAIL CLOSED: merged reader seam mismatch")

path.write_text(text.replace(anchor, diagnostic + anchor, 1))
PY

printf '\n=== RUN REPOSITORY-LOCAL ISOLATION ===\n'
set +e
npx tsx --test --test-reporter=spec "$TMP_TEST" \
  >"$LOG" 2>&1
ISOLATION_STATUS=$?
set -e

printf 'ISOLATION_STATUS=%s\n' "$ISOLATION_STATUS"
cat "$LOG"

printf '\n=== EXACT READER RESULTS ===\n'
RESULT_LINE="$(
  grep -m1 'ATLAS_READER_ISOLATION_RESULTS=' "$LOG" || true
)"
printf '%s\n' "$RESULT_LINE"

printf '\n=== CLASSIFICATION ===\n'
if [ -n "$RESULT_LINE" ]; then
  FAIL_COUNT="$(
    printf '%s\n' "$RESULT_LINE" |
      grep -o '"status":"fail"' |
      wc -l |
      tr -d ' '
  )"

  echo "READER_ISOLATION_EXECUTED=YES"
  printf 'FAILING_READER_COUNT=%s\n' "$FAIL_COUNT"

  if [ "$FAIL_COUNT" = "1" ]; then
    echo "SINGLE_FAILING_READER_IDENTIFIED=YES"
    echo "NEXT_ACTION=CLASSIFY_EXACT_FIXTURE_DEPENDENCY_FOR_IDENTIFIED_READER"
  else
    echo "SINGLE_FAILING_READER_IDENTIFIED=NO"
    echo "NEXT_ACTION=CLASSIFY_REPORTED_READER_FAILURES_BEFORE_ATTEMPT_2"
  fi
else
  echo "READER_ISOLATION_EXECUTED=NO"
  echo "NEXT_ACTION=DIAGNOSE_REPOSITORY_LOCAL_ISOLATION_FAILURE_ONLY"
fi

printf '\n=== REMOVE TEMP DIAGNOSTIC ===\n'
rm -f "$TMP_TEST"
trap - EXIT
test ! -e "$TMP_TEST"

printf '\n=== VERIFY ORIGINAL AUTHORIZED TEST PRESERVED ===\n'
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

printf '\n=== STOP ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
echo "NO ATTEMPT 2 / NO TEST COMMIT / NO TEST PUSH"
