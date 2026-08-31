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

export interface RequestChangesUserPackageSemantics {
  expectedOutcome?: string | null;
  proposedWork?: string | null;
  proposedArtifacts?: string | null;
  inScope?: string | null;
  outOfScope?: string | null;
  constraints?: string | null;
  unresolvedQuestions?: string | null;
}

export interface RequestChangesResult {
  ok: true;
  route: "request_changes_route";
  result: {
    canonical_package_created: false;
    delegation_authorized: false;
    validation_authorized: false;
    envelope_authorized: false;
    execution_authorized: false;
  };
  canonical_package_created: false;
  delegation_authorized: false;
  validation_authorized: false;
  envelope_authorized: false;
  execution_authorized: false;
}

export interface CanonicalPackageApprovalResult {
  ok: true;
  route: "matilda_canonical_package_route";
  package: {
    package_id: string;
    summary_id: string;
    draft_package_id: string;
    lineage_id: string;
    project_id: string;
    conversation_id: string | null;
    approved_interpretation: string;
    approved_work: string | null;
    approved_artifacts: string | null;
    approved_scope: string | null;
    approved_constraints: string | null;
    approved_expected_outcome: string | null;
    approval_actor: string;
    approval_timestamp: string;
    status: "canonical_approved";
    created_at: string;
    delegation_authorized: false;
    validation_authorized: false;
    envelope_authorized: false;
    execution_authorized: false;
  };
  delegation_authorized: false;
  validation_authorized: false;
  envelope_authorized: false;
  execution_authorized: false;
}

function requireText(
  value: string,
  fieldName: string,
): string {
  const normalized = value.trim();

  if (!normalized) {
    throw new Error(`${fieldName} is required.`);
  }

  return normalized;
}

async function readApiError(
  response: Response,
  fallback: string,
): Promise<string> {
  try {
    const body = await response.json() as {
      error?: unknown;
    };

    if (
      typeof body.error === "string" &&
      body.error.trim()
    ) {
      return body.error;
    }
  } catch {
    // Preserve the executive-safe fallback.
  }

  return fallback;
}

export async function fetchApprovalRequests(
  projectId: string,
): Promise<ApprovalRequestCollection> {
  const normalizedProjectId = requireText(
    projectId,
    "projectId",
  );

  const response = await fetch(
    `/api/approval-requests?project_id=${encodeURIComponent(
      normalizedProjectId,
    )}`,
  );

  if (!response.ok) {
    throw new Error(
      await readApiError(
        response,
        "Unable to load approval requests.",
      ),
    );
  }

  return response.json() as Promise<ApprovalRequestCollection>;
}

export async function requestChanges(
  approvalRequestId: string,
  feedback: string,
  userPackageSemantics?: RequestChangesUserPackageSemantics | null,
): Promise<RequestChangesResult> {
  const normalizedApprovalRequestId = requireText(
    approvalRequestId,
    "approvalRequestId",
  );
  const normalizedFeedback = requireText(
    feedback,
    "feedback",
  );

  const response = await fetch(
    "/api/request-changes",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        approval_request_id: normalizedApprovalRequestId,
        feedback: normalizedFeedback,
        ...(userPackageSemantics
          ? {
              user_package_semantics:
                userPackageSemantics,
            }
          : {}),
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      await readApiError(
        response,
        "The changes request could not be submitted.",
      ),
    );
  }

  return response.json() as Promise<RequestChangesResult>;
}

export async function approveCanonicalPackage(
  draftPackageId: string,
): Promise<CanonicalPackageApprovalResult> {
  const normalizedDraftPackageId = requireText(
    draftPackageId,
    "draftPackageId",
  );

  const response = await fetch(
    "/api/matilda/canonical-package",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        draft_package_id: normalizedDraftPackageId,
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      await readApiError(
        response,
        "The Package could not be approved.",
      ),
    );
  }

  return response.json() as Promise<CanonicalPackageApprovalResult>;
}
