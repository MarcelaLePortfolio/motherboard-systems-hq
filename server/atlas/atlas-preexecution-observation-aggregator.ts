import {
  readAtlasPreExecutionObservations,
  type AtlasPreExecutionObservation,
} from "./atlas-preexecution-read-model";

import {
  readAtlasLivingDraftObservations,
  readAtlasPendingApprovalObservations,
  type AtlasLivingDraftObservation,
  type AtlasPendingApprovalObservation,
} from "./atlas-draft-approval-observation";

import {
  readAtlasCanonicalPackageObservations,
  type AtlasCanonicalPackageObservation,
} from "./atlas-canonical-package-observation";
import {
  readAtlasHistoricalTypedObservations,
} from "./atlas-historical-observation-adapter";

export type AtlasTypedPreexecutionObservation =
  | {
      sourceKind: "interpretation_evidence";
      authorityStatus: "matilda_authored_interpretive_evidence";
      projectId: string;
      conversationId: string | null;
      lineageId: string | null;
      observedAt: string;
      payload: AtlasPreExecutionObservation;
    }
  | {
      sourceKind: "living_draft";
      authorityStatus: "non_authoritative";
      projectId: string;
      conversationId: string | null;
      lineageId: string;
      observedAt: string;
      payload: AtlasLivingDraftObservation;
    }
  | {
      sourceKind: "pending_approval_request";
      authorityStatus: "pending_transition";
      projectId: string;
      conversationId: string | null;
      lineageId: string;
      observedAt: string;
      payload: AtlasPendingApprovalObservation;
    }
  | {
      sourceKind: "canonical_package";
      authorityStatus: "authoritative";
      projectId: string;
      conversationId: string | null;
      lineageId: string;
      observedAt: string;
      payload: AtlasCanonicalPackageObservation;
    };

function requireProjectId(projectId: string): string {
  const normalized = projectId.trim();

  if (!normalized) {
    throw new Error(
      "projectId is required for Atlas typed pre-execution observation aggregation.",
    );
  }

  return normalized;
}

function assertProjectScope(
  expectedProjectId: string,
  actualProjectId: string,
  sourceKind: AtlasTypedPreexecutionObservation["sourceKind"],
): void {
  if (actualProjectId !== expectedProjectId) {
    throw new Error(
      `Atlas ${sourceKind} observation violated project scope.`,
    );
  }
}

function stableIdentity(
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
  if (timeOrder !== 0) return timeOrder;

  const sourceOrder = left.sourceKind.localeCompare(right.sourceKind);
  if (sourceOrder !== 0) return sourceOrder;

  return stableIdentity(left).localeCompare(stableIdentity(right));
}

export function aggregateAtlasPreExecutionObservationRecords(
  projectId: string,
  input: {
    interpretationEvidence: readonly AtlasPreExecutionObservation[];
    livingDrafts: readonly AtlasLivingDraftObservation[];
    pendingApprovals: readonly AtlasPendingApprovalObservation[];
    canonicalPackages: readonly AtlasCanonicalPackageObservation[];
  },
): AtlasTypedPreexecutionObservation[] {
  const normalizedProjectId = requireProjectId(projectId);
  const observations: AtlasTypedPreexecutionObservation[] = [];

  for (const payload of input.interpretationEvidence) {
    assertProjectScope(
      normalizedProjectId,
      payload.projectId,
      "interpretation_evidence",
    );

    observations.push({
      sourceKind: "interpretation_evidence",
      authorityStatus: "matilda_authored_interpretive_evidence",
      projectId: payload.projectId,
      conversationId: payload.conversationId,
      lineageId: payload.lineageReferences ?? null,
      observedAt: payload.createdAt,
      payload,
    });
  }

  for (const payload of input.livingDrafts) {
    assertProjectScope(
      normalizedProjectId,
      payload.projectId,
      "living_draft",
    );

    observations.push({
      sourceKind: "living_draft",
      authorityStatus: "non_authoritative",
      projectId: payload.projectId,
      conversationId: payload.conversationId,
      lineageId: payload.lineageId,
      observedAt: payload.updatedAt,
      payload,
    });
  }

  for (const payload of input.pendingApprovals) {
    assertProjectScope(
      normalizedProjectId,
      payload.projectId,
      "pending_approval_request",
    );

    observations.push({
      sourceKind: "pending_approval_request",
      authorityStatus: "pending_transition",
      projectId: payload.projectId,
      conversationId: payload.conversationId,
      lineageId: payload.lineageId,
      observedAt: payload.updatedAt,
      payload,
    });
  }

  for (const payload of input.canonicalPackages) {
    assertProjectScope(
      normalizedProjectId,
      payload.projectId,
      "canonical_package",
    );

    observations.push({
      sourceKind: "canonical_package",
      authorityStatus: "authoritative",
      projectId: payload.projectId,
      conversationId: payload.conversationId,
      lineageId: payload.lineageId,
      observedAt: payload.approvalTimestamp,
      payload,
    });
  }

  return observations.sort(compareObservations);
}

export function readAtlasTypedPreexecutionObservations(
  scope: {
    projectId: string;
    conversationId: string;
    databasePath?: string;
  },
): AtlasTypedPreexecutionObservation[] {
  const normalizedProjectId = requireProjectId(scope.projectId);
  const normalizedConversationId = String(
    scope.conversationId || "",
  ).trim();

  if (!normalizedConversationId) {
    throw new Error(
      "conversationId is required for Atlas typed pre-execution observation aggregation.",
    );
  }

  const databasePath = scope.databasePath ?? "db/main.db";

  const liveObservations =
    aggregateAtlasPreExecutionObservationRecords(
      normalizedProjectId,
      {
        interpretationEvidence: readAtlasPreExecutionObservations({
          projectId: normalizedProjectId,
          conversationId: normalizedConversationId,
        }),
        livingDrafts: readAtlasLivingDraftObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
        pendingApprovals: readAtlasPendingApprovalObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
        canonicalPackages: readAtlasCanonicalPackageObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
      },
    );

  const historicalObservations =
    readAtlasHistoricalTypedObservations(
      normalizedProjectId,
      databasePath,
    ).filter(
      (historical) =>
        historical.observation.conversationId ===
        normalizedConversationId,
    );

  const liveInterpretationEntryIds = new Set(
    liveObservations
      .filter(
        (observation) =>
          observation.sourceKind === "interpretation_evidence",
      )
      .map(
        (observation) =>
          observation.payload.entryId,
      ),
  );

  const liveDraftRevisionKeys = new Set(
    liveObservations
      .filter(
        (observation) =>
          observation.sourceKind === "living_draft",
      )
      .map(
        (observation) =>
          `${observation.payload.draftPackageId}\u0000${observation.payload.updatedAt}`,
      ),
  );

  const historicalTypedObservations =
    historicalObservations
      .filter((historical) => {
        if (
          historical.observationKind ===
          "interpretation_evidence"
        ) {
          return !liveInterpretationEntryIds.has(
            historical.observation.entryId,
          );
        }

        return !liveDraftRevisionKeys.has(
          `${historical.observation.draftPackageId}\u0000${historical.observation.updatedAt}`,
        );
      })
      .map(
        (historical): AtlasTypedPreexecutionObservation => {
          if (
            historical.observationKind ===
            "interpretation_evidence"
          ) {
            return {
              sourceKind: "interpretation_evidence",
              authorityStatus:
                historical.authorityStatus,
              projectId:
                historical.observation.projectId,
              conversationId:
                historical.observation.conversationId,
              lineageId:
                historical.observation.lineageReferences ?? null,
              observedAt:
                historical.observation.createdAt,
              payload:
                historical.observation,
            };
          }

          return {
            sourceKind: "living_draft",
            authorityStatus: "non_authoritative",
            projectId:
              historical.observation.projectId,
            conversationId:
              historical.observation.conversationId,
            lineageId:
              historical.observation.lineageId,
            observedAt:
              historical.observation.updatedAt,
            payload:
              historical.observation,
          };
        },
      );

  return [
    ...liveObservations,
    ...historicalTypedObservations,
  ].sort(compareObservations);
}
