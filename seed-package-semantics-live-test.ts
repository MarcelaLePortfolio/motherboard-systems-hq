import {
  createMatildaConversation,
} from "./db/matilda-conversation-runtime";

import {
  runMatildaConversationWorkflow,
} from "./server/matilda-chat-workflow";

async function main(): Promise<void> {
  const conversation =
    createMatildaConversation("hq");

  const result =
    await runMatildaConversationWorkflow({
      project_id: "hq",
      conversation_id:
        conversation.conversation_id,
      agent: "matilda",
      message: `
Create a Living Draft package for this internal test request.

Expected outcome: one reviewable checklist that can be used to visually verify the Approvals interface.

Proposed work: create a short verification checklist covering the actual package contents shown during approval review.

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
        conversation_id:
          conversation.conversation_id,
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
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
