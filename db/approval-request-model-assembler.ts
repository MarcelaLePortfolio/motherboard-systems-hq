import type {
  ApprovalRequestSourceRecord,
} from "./approval-request-repository";

import {
  assembleReconciledInterpretationSummary,
} from "./matilda-reconciled-intent-runtime";

export type ApprovalRequestKind =
  | "canonical_package_approval";

export type ApprovalRequestStatus =
  | "pending";

export type ApprovalRequestDecision =
  | "approve_canonical_package";

export interface ApprovalRequestEvidence {
  evidence_entry_ids: string[];
  interpreted_objective: string;
  proposed_work: string | null;
  proposed_artifacts: string | null;
  in_scope: string | null;
  out_of_scope: string | null;
  constraints: string | null;
  expected_outcome: string | null;
  unresolved_questions: string | null;
}

export interface ApprovalRequestReadModel {
  approval_request_id: string;
  kind: ApprovalRequestKind;
  status: ApprovalRequestStatus;
  project_id: string;
  conversation_id: string | null;
  lineage_id: string;
  draft_package_id: string;
  executive_question: string;
  available_decisions: ApprovalRequestDecision[];
  source_draft_status: string;
  evidence: ApprovalRequestEvidence;
  created_at: string;
  updated_at: string;
}

export interface ApprovalRequestReadCollection {
  project_id: string;
  requests: ApprovalRequestReadModel[];
}

function requireText(value: string, field: string): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(
      `Approval Request source field ${field} is required.`,
    );
  }

  return normalized;
}

function parseEvidenceEntryIds(value: string): string[] {
  let parsed: unknown;

  try {
    parsed = JSON.parse(value);
  } catch {
    throw new Error(
      "Approval Request source contains invalid evidence_entry_ids JSON.",
    );
  }

  if (!Array.isArray(parsed)) {
    throw new Error(
      "Approval Request source evidence_entry_ids must be an array.",
    );
  }

  return [...new Set(parsed.map(String).filter(Boolean))];
}

export function assembleApprovalRequestReadModel(
  source: ApprovalRequestSourceRecord,
): ApprovalRequestReadModel {
  const draftPackageId = requireText(
    source.draft_package_id,
    "draft_package_id",
  );

  const summary = assembleReconciledInterpretationSummary({
    draft_package_id: draftPackageId,
    lineage_id: requireText(
      source.lineage_id,
      "lineage_id",
    ),
    project_id: requireText(
      source.project_id,
      "project_id",
    ),
    conversation_id: source.conversation_id,
    current_interpretation: requireText(
      source.current_interpretation,
      "current_interpretation",
    ),
    proposed_work: source.proposed_work,
    proposed_artifacts: source.proposed_artifacts,
    in_scope: source.in_scope,
    out_of_scope: source.out_of_scope,
    constraints: source.constraints,
    expected_outcome: source.expected_outcome,
    unresolved_questions: source.unresolved_questions,
    evidence_entry_ids: parseEvidenceEntryIds(
      source.evidence_entry_ids,
    ),
    status: requireText(
      source.source_draft_status,
      "source_draft_status",
    ),
  });

  return {
    approval_request_id:
      `canonical_package_approval:${draftPackageId}`,
    kind: "canonical_package_approval",
    status: "pending",
    project_id: requireText(
      summary.project_id ?? "",
      "project_id",
    ),
    conversation_id: summary.conversation_id,
    lineage_id: summary.lineage_id,
    draft_package_id: summary.draft_package_id,
    executive_question:
      "Should this Reconciled Interpretation Summary become the authoritative Canonical Package?",
    available_decisions: [
      "approve_canonical_package",
    ],
    source_draft_status: summary.source_draft_status,
    evidence: {
      evidence_entry_ids: summary.evidence_entry_ids,
      interpreted_objective: summary.interpreted_objective,
      proposed_work: summary.proposed_work,
      proposed_artifacts: summary.proposed_artifacts,
      in_scope: summary.in_scope,
      out_of_scope: summary.out_of_scope,
      constraints: summary.constraints,
      expected_outcome: summary.expected_outcome,
      unresolved_questions: summary.unresolved_questions,
    },
    created_at: requireText(
      source.created_at,
      "created_at",
    ),
    updated_at: requireText(
      source.updated_at,
      "updated_at",
    ),
  };
}

export function assembleApprovalRequestReadCollection(
  projectId: string,
  sources: ApprovalRequestSourceRecord[],
): ApprovalRequestReadCollection {
  const normalizedProjectId = requireText(
    projectId,
    "project_id",
  );

  const requests = sources.map((source) => {
    const request =
      assembleApprovalRequestReadModel(source);

    if (request.project_id !== normalizedProjectId) {
      throw new Error(
        "Approval Request source project does not match collection project.",
      );
    }

    return request;
  });

  return {
    project_id: normalizedProjectId,
    requests,
  };
}
