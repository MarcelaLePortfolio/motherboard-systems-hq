#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="40260676c"
TEST="server/matilda-chat-workflow.explicit-target.integration.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"
test -z "$(git diff -- "$TEST")"

python3 - <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
text = path.read_text()

import_anchor = 'import Database from "better-sqlite3";\n'

imports = '''import Database from "better-sqlite3";

import {
  readAtlasHistoricalObservations,
} from "../db/atlas-historical-observation-persistence";
import {
  readAtlasHistoricalTypedObservations,
} from "./atlas/atlas-historical-observation-adapter";
import {
  readAtlasTypedPreexecutionObservations,
} from "./atlas/atlas-preexecution-observation-aggregator";
'''

if text.count(import_anchor) != 1:
    raise SystemExit(
        f"FAIL CLOSED: import seam mismatch: {text.count(import_anchor)}"
    )

text = text.replace(import_anchor, imports, 1)

anchor = '''      const activeDraftCount =
        database
          .prepare(`'''

if text.count(anchor) != 1:
    raise SystemExit(
        f"FAIL CLOSED: assertion insertion seam mismatch: {text.count(anchor)}"
    )

assertions = '''      const historicalRecords =
        readAtlasHistoricalObservations(
          "hq",
          database,
        );

      const targetHistoricalRecords =
        historicalRecords.filter(
          (observation) =>
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      const historicalInterpretationEvidence =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "interpretation_evidence",
        );

      const historicalLivingDrafts =
        targetHistoricalRecords.filter(
          (observation) =>
            observation.sourceKind ===
            "living_draft",
        );

      assert.equal(
        historicalInterpretationEvidence.length,
        1,
      );

      assert.ok(
        historicalLivingDrafts.length >= 1,
      );

      assert.equal(
        historicalInterpretationEvidence[0]
          ?.authorityStatus,
        "matilda_authored_interpretive_evidence",
      );

      assert.ok(
        historicalLivingDrafts.every(
          (observation) =>
            observation.authorityStatus ===
            "non_authoritative" &&
            observation.conversationId ===
            explicitTargetConversation.conversation_id,
        ),
      );

      const databasePath =
        path.join(
          temporaryRoot,
          "db",
          "main.db",
        );

      const typedHistorical =
        readAtlasHistoricalTypedObservations(
          "hq",
          databasePath,
        ).filter(
          (observation) =>
            observation.observation.conversationId ===
            explicitTargetConversation.conversation_id,
        );

      assert.equal(
        typedHistorical.filter(
          (observation) =>
            observation.observationKind ===
            "interpretation_evidence",
        ).length,
        1,
      );

      assert.ok(
        typedHistorical
          .filter(
            (observation) =>
              observation.observationKind ===
              "living_draft",
          )
          .every(
            (observation) =>
              observation.authorityStatus ===
              "non_authoritative",
          ),
      );

      const merged =
        readAtlasTypedPreexecutionObservations({
          projectId: "hq",
          conversationId:
            explicitTargetConversation.conversation_id,
          databasePath,
        });

      const mergedInterpretationEvidence =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "interpretation_evidence" &&
            observation.payload.entryId ===
              afterTargetEntries[0]?.entry_id,
        );

      assert.equal(
        mergedInterpretationEvidence.length,
        1,
      );

      const mergedDrafts =
        merged.filter(
          (observation) =>
            observation.sourceKind ===
              "living_draft" &&
            observation.payload.draftPackageId ===
              draft.draft_package_id,
        );

      const mergedDraftRevisionKeys =
        mergedDrafts.map(
          (observation) =>
            `${observation.payload.draftPackageId}\\u0000${observation.payload.updatedAt}`,
        );

      assert.equal(
        new Set(mergedDraftRevisionKeys).size,
        mergedDraftRevisionKeys.length,
      );

      const chronological =
        merged.map(
          (observation) =>
            observation.observedAt,
        );

      assert.deepEqual(
        chronological,
        [...chronological].sort(),
      );

'''

text = text.replace(anchor, assertions + anchor, 1)
path.write_text(text)
PY

printf '\n=== VERIFY AUTHORIZED PATH ONLY ===\n'
git diff --name-only
test "$(git diff --name-only)" = "$TEST"

printf '\n=== DIFF CHECK ===\n'
git diff --check -- "$TEST"

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TSC_STATUS=$?
set -e
printf 'TSC_STATUS=%s\n' "$TSC_STATUS"

printf '\n=== AUTHORIZED INTEGRATION TEST ===\n'
set +e
npx tsx --test "$TEST"
TEST_STATUS=$?
set -e
printf 'TEST_STATUS=%s\n' "$TEST_STATUS"

printf '\n=== ATLAS REGRESSION SUITE ===\n'
set +e
npx tsx --test db/atlas-historical-observation-persistence.test.ts
PERSISTENCE_STATUS=$?
npx tsx --test server/atlas/atlas-historical-observation-adapter.test.ts
ADAPTER_STATUS=$?
npx tsx --test server/atlas/atlas-preexecution-observation-aggregator.test.ts
AGGREGATOR_STATUS=$?
npx tsx --test server/routes/atlas/preexecution.test.ts
ROUTE_STATUS=$?
set -e

printf 'PERSISTENCE_STATUS=%s\n' "$PERSISTENCE_STATUS"
printf 'ADAPTER_STATUS=%s\n' "$ADAPTER_STATUS"
printf 'AGGREGATOR_STATUS=%s\n' "$AGGREGATOR_STATUS"
printf 'ROUTE_STATUS=%s\n' "$ROUTE_STATUS"

printf '\n=== PROTECTED PRODUCT BOUNDARIES ===\n'
PROTECTED_STATUS=0
git diff --exit-code -- \
  server/matilda-chat-workflow.ts \
  db/atlas-historical-observation-persistence.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts \
  server/routes/atlas/preexecution.ts \
  || PROTECTED_STATUS=$?

printf 'PROTECTED_STATUS=%s\n' "$PROTECTED_STATUS"

printf '\n=== CLASSIFICATION ===\n'
if [ "$TSC_STATUS" -eq 0 ] && \
   [ "$TEST_STATUS" -eq 0 ] && \
   [ "$PERSISTENCE_STATUS" -eq 0 ] && \
   [ "$ADAPTER_STATUS" -eq 0 ] && \
   [ "$AGGREGATOR_STATUS" -eq 0 ] && \
   [ "$ROUTE_STATUS" -eq 0 ] && \
   [ "$PROTECTED_STATUS" -eq 0 ]; then
  echo "ATLAS_LIFECYCLE_TEST_ONLY_VALIDATION_ATTEMPT_1=VALIDATED_LOCAL_ONLY"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=0"
  echo "AUTHORIZED_TEST_PATH_ONLY=YES"
  echo "PRODUCT_CODE_CHANGED=NO"
  echo "LIVE_DOGFOOD_EXECUTED=NO"
  echo "PRODUCTION_DATABASE_MUTATED=NO"
  echo "DESTRUCTIVE_CLEANUP=NO"
  echo "AUTHORITY_CHANGE=NO"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_GATE=TEST_COMMIT_AND_PUSH_AUTHORIZATION"
else
  echo "ATLAS_LIFECYCLE_TEST_ONLY_VALIDATION_ATTEMPT_1=FAILED_OR_BLOCKED"
  echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=1"
  echo "CLEAR_STOPPING_POINT=YES"
  echo "NEXT_ACTION=DIAGNOSE_ATTEMPT_1_ONLY"
fi

printf '\n=== STATUS ===\n'
git status --short -- "$TEST"

printf '\n=== STOP ===\n'
echo "NO TEST COMMIT / NO TEST PUSH"
