#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== SEED PACKAGE SEMANTICS LIVE TEST ==="
echo "PURPOSE=CREATE_ONE_FRESH_LIVING_DRAFT_THROUGH_REAL_MATILDA_WORKFLOW"
echo "DIRECT_DB_SEED=NO"
echo "HISTORICAL_BACKFILL=NO"
echo "AUTHORITY_TRANSITION=NO"
echo "PROJECT_ID=hq"

CONVERSATION_ID="package-semantics-live-seed-20260826"

cat > /tmp/seed-package-semantics-live-test.ts <<'TS'
import { runMatildaConversationWorkflow } from process.cwd() + "/server/matilda-chat-workflow";

const conversationId =
  "package-semantics-live-seed-20260826";

const result =
  await runMatildaConversationWorkflow({
    project_id: "hq",
    conversation_id: conversationId,
    agent: "matilda",
    message: `
Create a Living Draft package for this internal test request:

Objective: prepare a concise operator-facing checklist for verifying that a newly created approval package displays its actual package contents correctly.

Expected outcome: one reviewable checklist that can be used to visually verify the Approvals interface.

Proposed work: create a short verification checklist covering objective, expected outcome, proposed work, deliverables, in-scope work, out-of-scope work, constraints, and unresolved questions.

Proposed artifact: Package Approval UI Verification Checklist.

In scope: verifying that request-specific package semantics flow into the Living Draft and are visible when the package reaches approval review.

Out of scope: changing application code, changing approval authority, changing execution behavior, modifying historical packages, or approving the package automatically.

Constraints: preserve the existing one-message/one-workflow/one-Ollama-invocation architecture and keep the Living Draft non-authoritative until explicit user approval.

Unresolved question: whether the final Approvals presentation needs any additional visual refinement after the request-specific values are visible.
`.trim(),
  });

console.log(
  JSON.stringify(
    {
      conversation_id: conversationId,
      reply: result.reply,
      draft_package_updated:
        result.draft_package_updated,
      canonical_package_created:
        result.canonical_package_created,
      execution_authorized:
        result.execution_authorized,
      interpretation_entry_id:
        result.meta.interpretation_entry_id,
    },
    null,
    2,
  ),
);
TS

npx tsx /tmp/seed-package-semantics-live-test.ts
rm /tmp/seed-package-semantics-live-test.ts

echo
echo "SEED_COMPLETE=YES"
echo "CONVERSATION_ID=${CONVERSATION_ID}"
echo "EXPECTED_RESULT=NEW_REQUEST_SPECIFIC_LIVING_DRAFT"
echo "NEXT_ACTION=OPEN_THE_NEW_LIVING_DRAFT_AND_SUBMIT_IT_FOR_APPROVAL_THROUGH_THE_NORMAL_UI_SO_WE_CAN_INSPECT_THE_APPROVAL_CARDS"
