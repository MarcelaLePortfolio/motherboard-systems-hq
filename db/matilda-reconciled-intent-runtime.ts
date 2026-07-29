import { randomUUID } from "node:crypto";

import { getLivingDraftPackageById } from "./matilda-living-draft-read-runtime";

export type GenerateReconciledIntentSummaryInput = {
  draft_package_id?: string;
};

export type ReconciledIntentSummary = {
  summary_id: string;
  draft_package_id: string;
  lineage_id: string;
  project_id: string | null;
  conversation_id: string | null;
  interpreted_objective: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string[];
  source_draft_status: string;
  approval_required: true;
  generated_at: string;
};

function requireDraftPackageId(value: unknown): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error("draft_package_id is required");
  }

  return value.trim();
}

export function generateReconciledIntentSummary(
  input: GenerateReconciledIntentSummaryInput = {},
): ReconciledIntentSummary {
  const draft = getLivingDraftPackageById(
    requireDraftPackageId(input.draft_package_id),
  );

  return {
    summary_id: randomUUID(),
    draft_package_id: draft.draft_package_id,
    lineage_id: draft.lineage_id,
    project_id: draft.project_id,
    conversation_id: draft.conversation_id,
    interpreted_objective: draft.current_interpretation,
    proposed_work: draft.proposed_work,
    proposed_artifacts: draft.proposed_artifacts,
    in_scope: draft.in_scope,
    out_of_scope: draft.out_of_scope,
    constraints: draft.constraints,
    expected_outcome: draft.expected_outcome,
    unresolved_questions: draft.unresolved_questions,
    evidence_entry_ids: draft.evidence_entry_ids,
    source_draft_status: draft.status,
    approval_required: true,
    generated_at: new Date().toISOString(),
  };
}
