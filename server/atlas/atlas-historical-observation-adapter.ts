import {
  readAtlasHistoricalObservations,
  type AtlasHistoricalObservationRecord,
} from "../../db/atlas-historical-observation-persistence";
import type { AtlasPreExecutionObservation } from "./atlas-preexecution-read-model";
import type { AtlasLivingDraftObservation } from "./atlas-draft-approval-observation";

export type AtlasHistoricalTypedObservation =
  | {
      observationKind: "interpretation_evidence";
      authorityStatus: "matilda_authored_interpretive_evidence";
      sourceIdentity: string;
      observedAt: string;
      observation: AtlasPreExecutionObservation;
    }
  | {
      observationKind: "living_draft";
      authorityStatus: "non_authoritative";
      sourceIdentity: string;
      observedAt: string;
      observation: AtlasLivingDraftObservation;
    };

function requireObject(
  value: unknown,
  source: string,
): Record<string, unknown> {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `Atlas historical ${source} payload must be an object.`,
    );
  }

  return value as Record<string, unknown>;
}

function requireString(
  value: unknown,
  field: string,
): string {
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(
      `Atlas historical observation requires ${field}.`,
    );
  }

  return value;
}

function nullableString(
  value: unknown,
  field: string,
): string | null {
  if (value === null) return null;

  if (typeof value !== "string") {
    throw new Error(
      `Atlas historical observation requires nullable ${field}.`,
    );
  }

  return value;
}

function requireMatchingScope(
  record: AtlasHistoricalObservationRecord,
  projectId: unknown,
  conversationId: unknown,
): void {
  if (
    projectId !== record.projectId ||
    conversationId !== record.conversationId
  ) {
    throw new Error(
      "Atlas historical observation payload violated persisted scope.",
    );
  }
}

function adaptHistoricalInterpretationEvidence(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  if (
    record.authorityStatus !==
    "matilda_authored_interpretive_evidence"
  ) {
    throw new Error(
      "Atlas historical interpretation evidence authority status is invalid.",
    );
  }

  const payload = requireObject(
    record.payload,
    "interpretation evidence",
  );

  requireMatchingScope(
    record,
    payload.projectId,
    payload.conversationId,
  );

  return {
    observationKind: "interpretation_evidence",
    authorityStatus:
      "matilda_authored_interpretive_evidence",
    sourceIdentity: record.sourceIdentity,
    observedAt: record.observedAt,
    observation: {
      entryId: requireString(payload.entryId, "entryId"),
      createdAt: requireString(
        payload.createdAt,
        "createdAt",
      ),
      actor: requireString(payload.actor, "actor"),
      projectId: record.projectId,
      conversationId: record.conversationId,
      interpretationEvent: requireString(
        payload.interpretationEvent,
        "interpretationEvent",
      ),
      minimumSufficientContext: requireString(
        payload.minimumSufficientContext,
        "minimumSufficientContext",
      ),
      supportingRawEvidence: requireString(
        payload.supportingRawEvidence,
        "supportingRawEvidence",
      ),
      matildaObservation: requireString(
        payload.matildaObservation,
        "matildaObservation",
      ),
      unresolvedQuestions: nullableString(
        payload.unresolvedQuestions,
        "unresolvedQuestions",
      ),
      lineageReferences: nullableString(
        payload.lineageReferences,
        "lineageReferences",
      ),
      investigationLifecycle:
        payload.investigationLifecycle as AtlasPreExecutionObservation["investigationLifecycle"],
      packageSemantics:
        payload.packageSemantics as AtlasPreExecutionObservation["packageSemantics"],
      supersessionStatus: requireString(
        payload.supersessionStatus,
        "supersessionStatus",
      ),
    },
  };
}

function adaptHistoricalLivingDraft(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  if (record.authorityStatus !== "non_authoritative") {
    throw new Error(
      "Atlas historical Living Draft authority status must remain non_authoritative.",
    );
  }

  const payload = requireObject(
    record.payload,
    "Living Draft",
  );

  const projectId = requireString(
    payload.project_id,
    "project_id",
  );
  const conversationId = nullableString(
    payload.conversation_id,
    "conversation_id",
  );

  requireMatchingScope(
    record,
    projectId,
    conversationId,
  );

  return {
    observationKind: "living_draft",
    authorityStatus: "non_authoritative",
    sourceIdentity: record.sourceIdentity,
    observedAt: record.observedAt,
    observation: {
      observationKind: "living_draft",
      authorityStatus: "non_authoritative",
      draftPackageId: requireString(
        payload.draft_package_id,
        "draft_package_id",
      ),
      lineageId: requireString(
        payload.lineage_id,
        "lineage_id",
      ),
      projectId,
      conversationId,
      currentInterpretation: requireString(
        payload.current_interpretation,
        "current_interpretation",
      ),
      proposedWork: nullableString(
        payload.proposed_work,
        "proposed_work",
      ),
      proposedArtifacts: nullableString(
        payload.proposed_artifacts,
        "proposed_artifacts",
      ),
      inScope: nullableString(
        payload.in_scope,
        "in_scope",
      ),
      outOfScope: nullableString(
        payload.out_of_scope,
        "out_of_scope",
      ),
      constraints: nullableString(
        payload.constraints,
        "constraints",
      ),
      expectedOutcome: nullableString(
        payload.expected_outcome,
        "expected_outcome",
      ),
      unresolvedQuestions: nullableString(
        payload.unresolved_questions,
        "unresolved_questions",
      ),
      evidenceEntryIds: requireString(
        payload.evidence_entry_ids,
        "evidence_entry_ids",
      ),
      sourceStatus: requireString(
        payload.status,
        "status",
      ),
      createdAt: requireString(
        payload.created_at,
        "created_at",
      ),
      updatedAt: requireString(
        payload.updated_at,
        "updated_at",
      ),
    },
  };
}

export function adaptAtlasHistoricalObservation(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  switch (record.sourceKind) {
    case "interpretation_evidence":
      return adaptHistoricalInterpretationEvidence(record);
    case "living_draft":
      return adaptHistoricalLivingDraft(record);
  }
}

export function readAtlasHistoricalTypedObservations(
  projectId: string,
): AtlasHistoricalTypedObservation[] {
  return readAtlasHistoricalObservations(projectId).map(
    adaptAtlasHistoricalObservation,
  );
}
