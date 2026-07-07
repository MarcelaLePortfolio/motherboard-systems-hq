
export type ReconciledIntentSummary = {

  summary_id: string;

  draft_package_id: string | null;

  lineage_id: string;

  interpreted_objective: string;

  proposed_work: any[];

  proposed_artifacts: any[];

  in_scope: any[];

  constraints: any[];

  expected_outcome: string;

  approval_required: boolean;

};

export function generateReconciledIntentSummary(input: any = {}): ReconciledIntentSummary {

  return {

    summary_id: crypto.randomUUID?.() ?? "temp-id",

    draft_package_id: input?.draft_package_id ?? null,

    lineage_id: "temp-lineage",

    interpreted_objective: "pending",

    proposed_work: [],

    proposed_artifacts: [],

    in_scope: [],

    constraints: [],

    expected_outcome: "pending",

    approval_required: false

  };

}

