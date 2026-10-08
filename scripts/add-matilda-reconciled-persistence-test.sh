#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="280fafc07"
TARGET="server/matilda-chat-workflow.explicit-target.integration.test.ts"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test -z "$(git status --short -- "$TARGET" scripts/utils/ollamaChat.ts)"

python3 - << 'PY'
from pathlib import Path

target = Path("server/matilda-chat-workflow.explicit-target.integration.test.ts")
source = target.read_text()

old = '''            packageSemantics: {
              expectedOutcome:
                "Preserve the reviewed intent with the requested correction.",
              successCriteria: null,
              proposedWork:
                "Revise the reviewed interpretation using the supplied feedback.",
              proposedArtifacts: null,
              inScope:
                "The requested correction to the reviewed interpretation.",
              outOfScope:
                "Canonical approval and all downstream execution authority.",
              constraints:
                "Remain non-authoritative until separately approved.",
              unresolvedQuestions: null,
            },'''

new = '''            packageSemantics:
              latestOllamaRequestBody.includes(
                "Remove the Packages tab from the sidebar"
              )
                ? null
                : {
                    expectedOutcome:
                      "Preserve the reviewed intent with the requested correction.",
                    successCriteria: null,
                    proposedWork:
                      "Revise the reviewed interpretation using the supplied feedback.",
                    proposedArtifacts: null,
                    inScope:
                      "The requested correction to the reviewed interpretation.",
                    outOfScope:
                      "Canonical approval and all downstream execution authority.",
                    constraints:
                      "Remain non-authoritative until separately approved.",
                    unresolvedQuestions: null,
                  },'''

if source.count(old) != 1:
    raise SystemExit("FAIL_CLOSED: Model fixture did not match verified baseline.")

source = source.replace(old, new, 1)

anchor = '''      const historicalRecords =
        readAtlasHistoricalObservations('''

addition = '''      const reconciliationRequest =
        "Remove the Packages tab from the sidebar while preserving underlying package functionality and authority.";

      const reconciledConversation =
        conversationRuntime.createMatildaConversation("hq");

      const reconciledResult =
        await workflowRuntime.runMatildaConversationWorkflow({
          message: reconciliationRequest,
          agent: "matilda",
          project_id: "hq",
          conversation_id: reconciledConversation.conversation_id,
        });

      assert.equal(reconciledResult.execution_authorized, false);
      assert.equal(reconciledResult.delegation_authorized, false);
      assert.equal(reconciledResult.canonical_package_created, false);

      const reconciledEntries =
        interpretationRuntime.listInterpretationEvidenceLedgerEntries(
          100,
          {
            projectId: "hq",
            conversationId: reconciledConversation.conversation_id,
          },
        );

      assert.equal(reconciledEntries.length, 1);

      const reconciledDraft =
        database.prepare(`
          SELECT expected_outcome, status
          FROM matilda_living_draft_packages
          WHERE conversation_id = ?
          LIMIT 1
        `).get(reconciledConversation.conversation_id) as
          | { expected_outcome: string | null; status: string }
          | undefined;

      assert.ok(reconciledDraft);
      assert.match(
        reconciledDraft.expected_outcome ?? "",
        /remove the Packages tab from the sidebar/i,
      );
      assert.match(
        reconciledDraft.expected_outcome ?? "",
        /preserving underlying package functionality and authority/i,
      );
      assert.equal(reconciledDraft.status, "draft_non_authoritative");

      const persistedSemantics =
        database.prepare(`
          SELECT package_semantics_json
          FROM matilda_interpretation_evidence_ledger
          WHERE conversation_id = ?
          ORDER BY created_at DESC
          LIMIT 1
        `).get(reconciledConversation.conversation_id) as
          | { package_semantics_json: string | null }
          | undefined;

      assert.ok(persistedSemantics?.package_semantics_json);

      const semantics = JSON.parse(
        persistedSemantics.package_semantics_json,
      ) as { expectedOutcome: string; proposedWork: string | null };

      assert.equal(
        semantics.expectedOutcome,
        reconciledDraft.expected_outcome,
      );
      assert.equal(semantics.proposedWork, null);

'''

if source.count(anchor) != 1:
    raise SystemExit("FAIL_CLOSED: Persistence assertion anchor not unique.")

source = source.replace(anchor, addition + anchor, 1)
target.write_text(source)
PY

echo "=== ISOLATED PERSISTENCE INTEGRATION ==="
npx tsx --test "$TARGET"

echo "=== TYPECHECK ==="
npx tsc --noEmit

echo "=== DIFF CHECK ==="
git diff --check

echo "RECONCILED_PERSISTENCE=PASS"
echo "PRODUCTION_SOURCE=UNCHANGED"
echo "FAILED_RECONCILIATION_DURABILITY=STILL_REQUIRED"
echo "CONTRADICTORY_NON_OUTCOME_SEMANTICS=STILL_REQUIRED"
echo "LIVE_DOGFOOD=NOT_PERFORMED"
echo "CORRIDOR=OPEN"
