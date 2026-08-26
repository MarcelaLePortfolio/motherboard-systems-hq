
import {

  listInterpretationEvidenceLedgerEntries,

} from "./matilda-interpretation-runtime";

import {

  upsertLivingDraftPackage,

} from "./matilda-living-draft-runtime";

export type SynthesizeLivingDraftInput = {

  draft_package_id: string;

  lineage_id: string;

  project_id?: string | null;

  conversation_id?: string | null;

  evidence_entry_ids: string[];

};

export function synthesizeLivingDraft(

  input: SynthesizeLivingDraftInput,

) {

  const ledger = listInterpretationEvidenceLedgerEntries(500);

  const evidence = ledger.filter((entry: any) =>

    input.evidence_entry_ids.includes(entry.entry_id),

  );

  if (evidence.length === 0) {

    throw new Error("No matching Interpretation Evidence Ledger entries found.");

  }

  if (input.project_id && input.conversation_id) {

    const mismatchedEvidence = evidence.find(
      (entry: any) =>
        entry.project_id !== input.project_id
        || entry.conversation_id !== input.conversation_id,
    );

    if (mismatchedEvidence) {

      throw new Error(
        `Interpretation evidence entry ${mismatchedEvidence.entry_id} does not belong to the requested project conversation.`,
      );

    }

  }

  const interpretation = evidence

    .map((entry: any) => entry.matilda_observation)

    .filter(Boolean)

    .join("\n\n");

  const selectedPackageSemantics = evidence

    .find((entry: any) => entry.packageSemantics !== null)

    ?.packageSemantics ?? null;

  return upsertLivingDraftPackage({

    draft_package_id: input.draft_package_id,

    lineage_id: input.lineage_id,

    project_id: input.project_id,

    conversation_id: input.conversation_id,

    current_interpretation: interpretation,

    proposed_work:

      selectedPackageSemantics?.proposedWork ?? null,

    proposed_artifacts:

      selectedPackageSemantics?.proposedArtifacts ?? null,

    in_scope:

      selectedPackageSemantics?.inScope ?? null,

    out_of_scope:

      selectedPackageSemantics?.outOfScope ?? null,

    constraints:

      selectedPackageSemantics?.constraints ?? null,

    expected_outcome:

      selectedPackageSemantics?.expectedOutcome ?? null,

    unresolved_questions:

      selectedPackageSemantics?.unresolvedQuestions ?? null,

    evidence_entry_ids: input.evidence_entry_ids,

    status: "draft_non_authoritative",

  });

}

