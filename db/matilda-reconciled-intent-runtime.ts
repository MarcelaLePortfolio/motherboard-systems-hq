import { randomUUID } from "node:crypto";

import { getDraftRevisionById } from "./matilda-draft-revision-runtime";
import { getLivingDraftPackageById } from "./matilda-living-draft-read-runtime";

export type GenerateReconciledIntentSummaryInput = {
  draft_package_id?: string;
  draft_revision_id?: string;
};

export type ReconciledIntentSummary = {
  summary_id: string;
  draft_package_id: string;
  draft_revision_id: string | null;
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

function normalizeOptionalId(value: unknown): string | null {
  if (typeof value !== "string") return null;

  const normalized = value.trim();

  return normalized.length > 0 ? normalized : null;
}

export function assembleReconciledInterpretationSummary(source: {
  draft_package_id: string;
  draft_revision_id?: string | null;
  lineage_id: string;
  project_id: string | null;
  conversation_id: string | null;
  current_interpretation: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
  evidence_entry_ids: string[];
  status: string;
}): ReconciledIntentSummary {
  return {
    summary_id: randomUUID(),
    draft_package_id: source.draft_package_id,
    draft_revision_id: source.draft_revision_id ?? null,
    lineage_id: source.lineage_id,
    project_id: source.project_id,
    conversation_id: source.conversation_id,
    interpreted_objective: source.current_interpretation,
    proposed_work: source.proposed_work,
    proposed_artifacts: source.proposed_artifacts,
    in_scope: source.in_scope,
    out_of_scope: source.out_of_scope,
    constraints: source.constraints,
    expected_outcome: source.expected_outcome,
    unresolved_questions: source.unresolved_questions,
    evidence_entry_ids: source.evidence_entry_ids,
    source_draft_status: source.status,
    approval_required: true,
    generated_at: new Date().toISOString(),
  };
}

export function generateReconciledIntentSummary(
  input: GenerateReconciledIntentSummaryInput = {},
): ReconciledIntentSummary {
  const draftPackageId = normalizeOptionalId(input.draft_package_id);
  const draftRevisionId = normalizeOptionalId(input.draft_revision_id);

  if (draftPackageId && draftRevisionId) {
    throw new Error(
      "Provide either draft_package_id or draft_revision_id, not both.",
    );
  }

  if (draftRevisionId) {
    const revision = getDraftRevisionById(draftRevisionId);

    return assembleReconciledInterpretationSummary({
      draft_package_id: revision.draft_package_id,
      draft_revision_id: revision.draft_revision_id,
      lineage_id: revision.lineage_id,
      project_id: revision.project_id,
      conversation_id: revision.conversation_id,
      current_interpretation: revision.current_interpretation,
      proposed_work: revision.proposed_work,
      proposed_artifacts: revision.proposed_artifacts,
      in_scope: revision.in_scope,
      out_of_scope: revision.out_of_scope,
      constraints: revision.constraints,
      expected_outcome: revision.expected_outcome,
      unresolved_questions: revision.unresolved_questions,
      evidence_entry_ids: revision.evidence_entry_ids,
      status: revision.status,
    });
  }

  if (!draftPackageId) {
    throw new Error("draft_package_id or draft_revision_id is required");
  }

  const draft = getLivingDraftPackageById(draftPackageId);

  return assembleReconciledInterpretationSummary({
    draft_package_id: draft.draft_package_id,
    draft_revision_id: null,
    lineage_id: draft.lineage_id,
    project_id: draft.project_id,
    conversation_id: draft.conversation_id,
    current_interpretation: draft.current_interpretation,
    proposed_work: draft.proposed_work,
    proposed_artifacts: draft.proposed_artifacts,
    in_scope: draft.in_scope,
    out_of_scope: draft.out_of_scope,
    constraints: draft.constraints,
    expected_outcome: draft.expected_outcome,
    unresolved_questions: draft.unresolved_questions,
    evidence_entry_ids: draft.evidence_entry_ids,
    status: draft.status,
  });
}
