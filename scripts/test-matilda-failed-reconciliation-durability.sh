#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="5b7cacf03"
TARGET="server/matilda-chat-workflow.explicit-target.integration.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" scripts/utils/ollamaChat.ts)"

python3 - << 'PY'
from pathlib import Path

target = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
source = target.read_text()

old = '''            packageSemantics:
              latestOllamaRequestBody.includes(
                "Remove the Packages tab from the sidebar"
              )
                ? null
                : {'''

new = '''            packageSemantics:
              latestOllamaRequestBody.includes(
                "Reject contradictory Package Semantics"
              )
                ? {
                    expectedOutcome: "Add a dashboard widget.",
                    successCriteria: null,
                    proposedWork: null,
                    proposedArtifacts: null,
                    inScope: null,
                    outOfScope: null,
                    constraints: null,
                    unresolvedQuestions: null,
                  }
                : latestOllamaRequestBody.includes(
                    "Remove the Packages tab from the sidebar"
                  )
                  ? null
                  : {'''

if source.count(old) != 1:
    raise SystemExit("FAIL_CLOSED: Model stub anchor is not unique.")

source = source.replace(old, new, 1)

anchor = '''      const historicalRecords =
        readAtlasHistoricalObservations('''

addition = '''      const rejectedConversation =
        conversationRuntime.createMatildaConversation("hq");

      const rejectedMessage =
        "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority. Reject contradictory Package Semantics.";

      await assert.rejects(
        () =>
          workflowRuntime.runMatildaConversationWorkflow({
            message: rejectedMessage,
            agent: "matilda",
            project_id: "hq",
            conversation_id: rejectedConversation.conversation_id,
          }),
      );

      const rejectedEntries =
        interpretationRuntime.listInterpretationEvidenceLedgerEntries(
          100,
          {
            projectId: "hq",
            conversationId: rejectedConversation.conversation_id,
          },
        );

      const rejectedTurns =
        conversationRuntime.listMatildaConversationTurns(
          "hq",
          100,
          rejectedConversation.conversation_id,
        );

      assert.equal(rejectedEntries.length, 0);
      assert.equal(rejectedTurns.length, 0);

      const rejectedDraftCount =
        database.prepare(`
          SELECT COUNT(*) AS count
          FROM matilda_living_draft_packages
          WHERE conversation_id = ?
        `).get(rejectedConversation.conversation_id) as {
          count: number;
        };

      assert.equal(rejectedDraftCount.count, 0);

      const rejectedHistoricalCount =
        database.prepare(`
          SELECT COUNT(*) AS count
          FROM atlas_historical_observations
          WHERE conversation_id = ?
        `).get(rejectedConversation.conversation_id) as {
          count: number;
        };

      assert.equal(rejectedHistoricalCount.count, 0);

'''

if source.count(anchor) != 1:
    raise SystemExit("FAIL_CLOSED: Persistence assertion anchor is not unique.")

source = source.replace(anchor, addition + anchor, 1)
target.write_text(source)
PY

echo "=== ISOLATED SUCCESS AND FAILURE DURABILITY ==="
npx tsx --test "$TARGET"

echo "=== TYPECHECK ==="
npx tsc --noEmit

echo "=== DIFF CHECK ==="
git diff --check

echo "RECONCILED_PERSISTENCE=PASS"
echo "FAILED_RECONCILIATION_DURABILITY=PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "CONTRADICTORY_NON_OUTCOME_SEMANTICS=STILL_REQUIRED"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
echo "CORRIDOR=OPEN"
