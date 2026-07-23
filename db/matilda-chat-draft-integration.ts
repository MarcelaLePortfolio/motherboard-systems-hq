
import { listMatildaConversationTurns } from "./matilda-conversation-runtime";

import { synthesizeLivingDraft } from "./matilda-draft-synthesis-runtime";

export type RunMatildaChatDraftIntegrationInput = {

  project_id: string;

  conversation_id: string;

  draft_package_id: string;

  lineage_id: string;

  latest_entry_id: string;

};

export function runMatildaChatDraftIntegration(

  input: RunMatildaChatDraftIntegrationInput,

) {

  const evidenceEntryIds = listMatildaConversationTurns(
    input.project_id,
    100,
    input.conversation_id,
  )

    .map((turn) => turn.interpretation_entry_id)

    .filter(Boolean);

  if (!evidenceEntryIds.includes(input.latest_entry_id)) {

    evidenceEntryIds.push(input.latest_entry_id);

  }

  const draft = synthesizeLivingDraft({

    draft_package_id: input.draft_package_id,

    lineage_id: input.lineage_id,

    evidence_entry_ids: evidenceEntryIds,

  });

  return {

    draft,

    canonical_package_created: false,

    delegation_authorized: false,

    validation_authorized: false,

    envelope_authorized: false,

    execution_authorized: false,

  };

}

