import {
  listInterpretationEvidenceLedgerEntries,
  type InterpretationEvidenceLedgerReadEntry,
} from "../../db/matilda-interpretation-runtime";

export type AtlasPreExecutionObservation = {
  entryId: string;
  createdAt: string;
  actor: string;
  projectId: string;
  conversationId: string;
  interpretationEvent: string;
  minimumSufficientContext: string;
  supportingRawEvidence: string;
  matildaObservation: string;
  unresolvedQuestions: string | null;
  lineageReferences: string | null;
  investigationLifecycle:
    InterpretationEvidenceLedgerReadEntry["investigationLifecycle"];
  packageSemantics:
    InterpretationEvidenceLedgerReadEntry["packageSemantics"];
  supersessionStatus: string;
};

export type AtlasPreExecutionObservationScope = {
  projectId: string;
  conversationId: string;
  limit?: number;
};

function requireScopedText(
  value: string | null,
  expected: string,
  field: "project_id" | "conversation_id",
): string {
  if (value !== expected) {
    throw new Error(
      `Atlas pre-execution observation violated ${field} scope.`,
    );
  }

  return value;
}

export function adaptInterpretationEvidenceForAtlas(
  entry: InterpretationEvidenceLedgerReadEntry,
  scope: Pick<
    AtlasPreExecutionObservationScope,
    "projectId" | "conversationId"
  >,
): AtlasPreExecutionObservation {
  return {
    entryId: entry.entry_id,
    createdAt: entry.created_at,
    actor: entry.actor,
    projectId: requireScopedText(
      entry.project_id,
      scope.projectId,
      "project_id",
    ),
    conversationId: requireScopedText(
      entry.conversation_id,
      scope.conversationId,
      "conversation_id",
    ),
    interpretationEvent: entry.interpretation_event,
    minimumSufficientContext: entry.minimum_sufficient_context,
    supportingRawEvidence: entry.supporting_raw_evidence,
    matildaObservation: entry.matilda_observation,
    unresolvedQuestions: entry.unresolved_questions,
    lineageReferences: entry.lineage_references,
    investigationLifecycle: entry.investigationLifecycle,
    packageSemantics: entry.packageSemantics,
    supersessionStatus: entry.supersession_status,
  };
}

export function readAtlasPreExecutionObservations(
  scope: AtlasPreExecutionObservationScope,
): AtlasPreExecutionObservation[] {
  const projectId = String(scope.projectId || "").trim();
  const conversationId = String(scope.conversationId || "").trim();

  if (!projectId) {
    throw new Error(
      "projectId is required for Atlas pre-execution observation.",
    );
  }

  if (!conversationId) {
    throw new Error(
      "conversationId is required for Atlas pre-execution observation.",
    );
  }

  const entries = listInterpretationEvidenceLedgerEntries(
    scope.limit ?? 20,
    {
      projectId,
      conversationId,
    },
  );

  return entries.map((entry) =>
    adaptInterpretationEvidenceForAtlas(entry, {
      projectId,
      conversationId,
    }),
  );
}
