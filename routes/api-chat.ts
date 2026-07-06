
/* Update this route so that after runMatildaStub() returns

   and exposes interpretation_entry_id, it immediately calls:

   runMatildaChatDraftIntegration({

     draft_package_id: "draft-active-conversation",

     lineage_id: "matilda-active-conversation",

     latest_entry_id: result.meta.interpretation_entry_id,

   });

   Preserve the existing chat response.

   Add to the JSON response:

   draft_package_updated: true,

   canonical_package_created: false,

   delegation_authorized: false,

   validation_authorized: false,

   envelope_authorized: false,

   execution_authorized: false

   Do not change the reply text.

   Do not expose the draft contents.

   Only trigger synthesis after successful IEL persistence.

   If synthesis fails, return the normal chat response and log the synthesis failure without failing the chat request.

*/

