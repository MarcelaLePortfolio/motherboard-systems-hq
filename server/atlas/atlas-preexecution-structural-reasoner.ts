import type {
  AtlasTypedPreexecutionObservation,
} from "./atlas-preexecution-observation-aggregator";

export type AtlasPreExecutionLineageSequence = {
  lineageId: string;
  conversationIds: string[];
  observationIds: string[];
  sourceSequence:
    AtlasTypedPreexecutionObservation["sourceKind"][];
  authoritySequence:
    AtlasTypedPreexecutionObservation["authorityStatus"][];
};

export type AtlasPreExecutionStructuralReasoningResult = {
  projectId: string;
  observations: AtlasTypedPreexecutionObservation[];
  lineageSequences: AtlasPreExecutionLineageSequence[];
};

function requireProjectId(projectId: string): string {
  const normalized = projectId.trim();

  if (!normalized) {
    throw new Error(
      "projectId is required for Atlas pre-execution structural reasoning.",
    );
  }

  return normalized;
}

function observationIdentity(
  observation: AtlasTypedPreexecutionObservation,
): string {
  switch (observation.sourceKind) {
    case "interpretation_evidence":
      return observation.payload.entryId;
    case "living_draft":
      return observation.payload.draftPackageId;
    case "pending_approval_request":
      return observation.payload.draftPackageId;
    case "canonical_package":
      return `${observation.payload.packageId}:${observation.payload.packageVersion}`;
  }
}

function compareObservations(
  left: AtlasTypedPreexecutionObservation,
  right: AtlasTypedPreexecutionObservation,
): number {
  const timeOrder = left.observedAt.localeCompare(right.observedAt);

  if (timeOrder !== 0) {
    return timeOrder;
  }

  const sourceOrder = left.sourceKind.localeCompare(right.sourceKind);

  if (sourceOrder !== 0) {
    return sourceOrder;
  }

  return observationIdentity(left).localeCompare(
    observationIdentity(right),
  );
}

export function reasonOverAtlasPreExecutionObservations(
  projectId: string,
  observations: readonly AtlasTypedPreexecutionObservation[],
): AtlasPreExecutionStructuralReasoningResult {
  const normalizedProjectId = requireProjectId(projectId);

  const ordered = [...observations].sort(compareObservations);

  for (const observation of ordered) {
    if (observation.projectId !== normalizedProjectId) {
      throw new Error(
        "Atlas pre-execution structural reasoning violated project scope.",
      );
    }
  }

  const byLineage = new Map<
    string,
    AtlasTypedPreexecutionObservation[]
  >();

  for (const observation of ordered) {
    if (!observation.lineageId) {
      continue;
    }

    const existing = byLineage.get(observation.lineageId);

    if (existing) {
      existing.push(observation);
    } else {
      byLineage.set(observation.lineageId, [observation]);
    }
  }

  const lineageSequences = Array.from(byLineage.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([lineageId, lineageObservations]) => {
      const conversationIds = Array.from(
        new Set(
          lineageObservations
            .map((observation) => observation.conversationId)
            .filter(
              (conversationId): conversationId is string =>
                typeof conversationId === "string"
                && conversationId.length > 0,
            ),
        ),
      );

      return {
        lineageId,
        conversationIds,
        observationIds:
          lineageObservations.map(observationIdentity),
        sourceSequence:
          lineageObservations.map(
            (observation) => observation.sourceKind,
          ),
        authoritySequence:
          lineageObservations.map(
            (observation) => observation.authorityStatus,
          ),
      };
    });

  return {
    projectId: normalizedProjectId,
    observations: ordered,
    lineageSequences,
  };
}
