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

export interface ApprovalRequestCollection {
  project_id: string;
  requests: ApprovalRequestReadModel[];
}

function requireProjectId(projectId: string): string {
  const normalized = projectId.trim();

  if (!normalized) {
    throw new Error("projectId is required.");
  }

  return normalized;
}

export async function fetchApprovalRequests(
  projectId: string,
): Promise<ApprovalRequestCollection> {
  const normalizedProjectId = requireProjectId(projectId);

  const response = await fetch(
    `/api/approval-requests?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
  );

  if (!response.ok) {
    throw new Error(
      `Approval Request API returned ${response.status}.`,
    );
  }

  return response.json() as Promise<ApprovalRequestCollection>;
}
