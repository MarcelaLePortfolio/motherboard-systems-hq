import {
  createPackageReadRepository,
  type LivingDraftPackageReadRecord,
} from "../../db/package-read-repository";

import {
  createApprovalRequestRepository,
  type ApprovalRequestSourceRecord,
} from "../../db/approval-request-repository";

export type AtlasLivingDraftObservation = {
  observationKind: "living_draft";
  authorityStatus: "non_authoritative";
  draftPackageId: string;
  lineageId: string;
  projectId: string;
  conversationId: string | null;
  currentInterpretation: string;
  proposedWork: string | null;
  proposedArtifacts: string | null;
  inScope: string | null;
  outOfScope: string | null;
  constraints: string | null;
  expectedOutcome: string | null;
  unresolvedQuestions: string | null;
  evidenceEntryIds: string;
  sourceStatus: string;
  createdAt: string;
  updatedAt: string;
};

export type AtlasPendingApprovalObservation = {
  observationKind: "pending_approval_request";
  authorityStatus: "pending_transition";
  draftPackageId: string;
  lineageId: string;
  projectId: string;
  conversationId: string | null;
  currentInterpretation: string;
  proposedWork: string | null;
  proposedArtifacts: string | null;
  inScope: string | null;
  outOfScope: string | null;
  constraints: string | null;
  expectedOutcome: string | null;
  unresolvedQuestions: string | null;
  evidenceEntryIds: string;
  sourceDraftStatus: string;
  createdAt: string;
  updatedAt: string;
};

function requireProjectScope(
  actualProjectId: string | null,
  expectedProjectId: string,
  source: string,
): string {
  if (actualProjectId !== expectedProjectId) {
    throw new Error(
      `Atlas ${source} observation violated project scope.`,
    );
  }

  return actualProjectId;
}

function requireProjectId(projectId: string): string {
  const normalized = projectId.trim();

  if (!normalized) {
    throw new Error(
      "projectId is required for Atlas draft and approval observation.",
    );
  }

  return normalized;
}

export function adaptLivingDraftForAtlas(
  record: LivingDraftPackageReadRecord,
  projectId: string,
): AtlasLivingDraftObservation {
  const normalizedProjectId = requireProjectId(projectId);

  return {
    observationKind: "living_draft",
    authorityStatus: "non_authoritative",
    draftPackageId: record.draft_package_id,
    lineageId: record.lineage_id,
    projectId: requireProjectScope(
      record.project_id,
      normalizedProjectId,
      "Living Draft",
    ),
    conversationId: record.conversation_id,
    currentInterpretation: record.current_interpretation,
    proposedWork: record.proposed_work,
    proposedArtifacts: record.proposed_artifacts,
    inScope: record.in_scope,
    outOfScope: record.out_of_scope,
    constraints: record.constraints,
    expectedOutcome: record.expected_outcome,
    unresolvedQuestions: record.unresolved_questions,
    evidenceEntryIds: record.evidence_entry_ids,
    sourceStatus: record.status,
    createdAt: record.created_at,
    updatedAt: record.updated_at,
  };
}

export function adaptPendingApprovalForAtlas(
  record: ApprovalRequestSourceRecord,
  projectId: string,
): AtlasPendingApprovalObservation {
  const normalizedProjectId = requireProjectId(projectId);

  return {
    observationKind: "pending_approval_request",
    authorityStatus: "pending_transition",
    draftPackageId: record.draft_package_id,
    lineageId: record.lineage_id,
    projectId: requireProjectScope(
      record.project_id,
      normalizedProjectId,
      "Pending Approval",
    ),
    conversationId: record.conversation_id,
    currentInterpretation: record.current_interpretation,
    proposedWork: record.proposed_work,
    proposedArtifacts: record.proposed_artifacts,
    inScope: record.in_scope,
    outOfScope: record.out_of_scope,
    constraints: record.constraints,
    expectedOutcome: record.expected_outcome,
    unresolvedQuestions: record.unresolved_questions,
    evidenceEntryIds: record.evidence_entry_ids,
    sourceDraftStatus: record.source_draft_status,
    createdAt: record.created_at,
    updatedAt: record.updated_at,
  };
}

export function readAtlasLivingDraftObservations(
  projectId: string,
  databasePath = "db/main.db",
): AtlasLivingDraftObservation[] {
  const normalizedProjectId = requireProjectId(projectId);
  const repository = createPackageReadRepository(databasePath);

  try {
    return repository
      .listLivingDraftPackagesByProject(normalizedProjectId)
      .map((record) =>
        adaptLivingDraftForAtlas(
          record,
          normalizedProjectId,
        ),
      );
  } finally {
    repository.close();
  }
}

export function readAtlasPendingApprovalObservations(
  projectId: string,
  databasePath = "db/main.db",
): AtlasPendingApprovalObservation[] {
  const normalizedProjectId = requireProjectId(projectId);
  const repository =
    createApprovalRequestRepository(databasePath);

  try {
    return repository
      .listPendingCanonicalPackageApprovalsByProject(
        normalizedProjectId,
      )
      .map((record) =>
        adaptPendingApprovalForAtlas(
          record,
          normalizedProjectId,
        ),
      );
  } finally {
    repository.close();
  }
}
