
import { listLivingDraftPackages } from "./matilda-living-draft-runtime.ts";

export type GenerateReconciledIntentSummaryInput = {

  draft_package_id: string;

};

export function generateReconciledIntentSummary(

  input: GenerateReconciledIntentSummaryInput,

) {

  const draft = listLivingDraftPackages(100).find(

    (d: any) => d.draft_package_id === input.draft_package_id,

  );

  if (!draft) {

    throw new Error(

      `Living Draft Package not found: ${input.draft_package_id}`,

    );

  }

  const created_at = new Date().toISOString();

  return {

    summary_id: `summary-${Date.now()}`,

    draft_package_id: draft.draft_package_id,

    lineage_id: draft.lineage_id,

    interpreted_objective: draft.current_interpretation,

    proposed_work: draft.proposed_work,

    proposed_artifacts: draft.proposed_artifacts,

    in_scope: draft.in_scope,

    out_of_scope: draft.out_of_scope,

    constraints: draft.constraints,

    expected_outcome: draft.expected_outcome,

    unresolved_questions: draft.unresolved_questions,

    recommended_next_action:

      "Present this Reconciled Intent Summary for explicit operator review and approval.",

    approval_required: true,

    status: "awaiting_operator_review",

    created_at,

    canonical_package_created: false,

    delegation_authorized: false,

    validation_authorized: false,

    envelope_authorized: false,

    execution_authorized: false,

  };

}

