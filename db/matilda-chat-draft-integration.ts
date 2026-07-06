
import { listInterpretationEvidenceLedgerEntries } from "./matilda-interpretation-runtime.ts";

import { synthesizeLivingDraftPackage } from "./matilda-draft-synthesis-runtime.ts";

export type RunMatildaChatDraftIntegrationInput = {

  draft_package_id: string;

  lineage_id: string;

  latest_entry_id: string;

};

export function runMatildaChatDraftIntegration(

  input: RunMatildaChatDraftIntegrationInput,

) {

  const entries = listInterpretationEvidenceLedgerEntries(100);

  const evidenceEntryIds = entries

    .filter((entry: any) => entry.entry_id)

    .map((entry: any) => entry.entry_id);

  if (!evidenceEntryIds.includes(input.latest_entry_id)) {

    evidenceEntryIds.unshift(input.latest_entry_id);

  }

  const draft = synthesizeLivingDraftPackage({

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

