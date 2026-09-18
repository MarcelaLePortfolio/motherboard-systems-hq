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

printf '\n=== ATTEMPT 1 STATE ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"

printf '\n=== LOCATE ISOLATED FIXTURE DB PATH ===\n'
grep -n -B10 -A25 -E \
  'temporaryRoot|main\.db|process\.chdir\(temporaryRoot\)' \
  "$TEST"

printf '\n=== LOCATE LIVE READER EXPORTS ===\n'
grep -n -B10 -A80 -E \
  '^export function readAtlasPreExecutionObservations|^export function readAtlasLivingDraftObservations|^export function readAtlasPendingApprovalObservations|^export function readAtlasCanonicalPackageObservations' \
  server/atlas/atlas-preexecution-read-model.ts \
  server/atlas/atlas-draft-approval-observation.ts \
  server/atlas/atlas-canonical-package-observation.ts

printf '\n=== CREATE TEMPORARY DIAGNOSTIC COPY OF TEST ===\n'
TMP_TEST="/tmp/matilda-chat-workflow.atlas-reader-isolation.test.ts"
cp "$TEST" "$TMP_TEST"

python3 - <<'PY'
from pathlib import Path

path = Path("/tmp/matilda-chat-workflow.atlas-reader-isolation.test.ts")
text = path.read_text()

import_anchor = '''import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";
'''

replacement = '''import {
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

if import_anchor not in text:
    raise SystemExit("FAIL CLOSED: import seam not found")

text = text.replace(import_anchor, replacement, 1)

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
          isolatedReaderResults.push({
            reader,
            status: "fail",
            error:
              error instanceof Error
                ? `${error.name}: ${error.message}`
                : String(error),
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

if anchor not in text:
    raise SystemExit("FAIL CLOSED: merged reader seam not found")

text = text.replace(anchor, diagnostic + anchor, 1)
path.write_text(text)
PY

printf '\n=== RUN TEMPORARY READER-ISOLATION TEST ===\n'
set +e
(
  cd "$(pwd)"
  npx tsx --test "$TMP_TEST"
) 2>&1 | tee /tmp/atlas-reader-isolation.log
ISOLATION_STATUS=${PIPESTATUS[0]}
set -e

printf 'ISOLATION_STATUS=%s\n' "$ISOLATION_STATUS"

printf '\n=== EXTRACT READER RESULTS ===\n'
grep -E \
  'ATLAS_READER_ISOLATION_RESULTS=|SQLITE_ERROR|no such table|no such column' \
  /tmp/atlas-reader-isolation.log \
  || true

printf '\n=== VERIFY ORIGINAL TEST UNCHANGED BY DIAGNOSTIC ===\n'
git diff --check -- "$TEST"
git status --short -- "$TEST"

printf '\n=== VERIFY PRODUCT SURFACES UNCHANGED ===\n'
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts

printf '\n=== CLASSIFICATION ===\n'
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
echo "ATTEMPT_2_AUTHORIZED=NO"
echo "ATTEMPT_2_EXECUTED=NO"
echo "PRODUCT_MUTATION=NO"
echo "TEST_COMMIT_AUTHORIZED=NO"
echo "TEST_PUSH_AUTHORIZED=NO"
echo "LIVE_DOGFOOD_AUTHORIZED=NO"
echo "DESTRUCTIVE_CLEANUP_AUTHORIZED=NO"
echo "NEXT_ACTION=USE_ATLAS_READER_ISOLATION_RESULTS_TO_IDENTIFY_SINGLE_FAILING_READER"
echo "BROADER_CORRIDOR_STATUS=ACTIVE"
echo "CLEAR_STOPPING_POINT=YES"
