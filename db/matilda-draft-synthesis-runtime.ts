
import {

  listInterpretationEvidenceLedgerEntries,

} from "./matilda-interpretation-runtime";

import {

  upsertLivingDraftPackage,

} from "./matilda-living-draft-runtime";

export type SynthesizeLivingDraftInput = {

  draft_package_id: string;

  lineage_id: string;

  evidence_entry_ids: string[];

};

export function synthesizeLivingDraft(

  input: SynthesizeLivingDraftInput,

) {

  const ledger = listInterpretationEvidenceLedgerEntries(500);

  const evidence = ledger.filter((entry: any) =>

    input.evidence_entry_ids.includes(entry.entry_id),

  );

  if (evidence.length === false) {

    throw new Error("No matching Interpretation Evidence Ledger entries found.");

  }

  const interpretation = evidence

    .map((entry: any) => entry.matilda_observation)

    .filter(Boolean)

    .join("\n\n");

  const unresolved = evidence

    .map((entry: any) => entry.unresolved_questions)

    .filter(Boolean)

    .join("\n");

  return upsertLivingDraftPackage({

    draft_package_id: input.draft_package_id,

    lineage_id: input.lineage_id,

    current_interpretation: interpretation,

    proposed_work:

      "Continue synthesizing interpretation evidence into a reviewable Living Draft Package.",

    proposed_artifacts:

      "Living Draft Package",

    in_scope:

      "Interpretation synthesis only.",

    out_of_scope:

      "Canonical Package creation, Delegation, Validation, Envelope creation, Routing, Assignment, Cade execution.",

    constraints:

      "Remain non-authoritative until explicit operator approval.",

    expected_outcome:

      "A continuously improving Living Draft Package.",

    unresolved_questions: unresolved,

    evidence_entry_ids: input.evidence_entry_ids,

    status: "draft_non_authoritative",

  });

}

