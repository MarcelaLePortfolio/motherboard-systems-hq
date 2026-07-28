import type {
  MissionReadModel,
  MissionStage,
  MissionOwner,
  MissionHealth,
} from "./mission-read-model-types.js";

export interface MissionLifecycleEvidence {
  transition_authorization: string;
  persisted_at: string;
}

export interface MissionAssemblyInput {
  package_id: string;
  package_version: number;
  project_id: string | null;

  lifecycle_state: string | null;

  lifecycle_event_count: number;
  lifecycle_events?: readonly MissionLifecycleEvidence[];

  integrity_warnings?: readonly string[];
}

function deriveStage(input: MissionAssemblyInput): MissionStage {
  switch (input.lifecycle_state) {
    case "ENVELOPE_CREATED":
      return "ENVELOPE_CREATED";

    case "ASSIGNED":
      return input.lifecycle_event_count > 0
        ? "ASSIGNED"
        : "UNKNOWN";

    default:
      return "UNKNOWN";
  }
}

function assembleTimeline(
  events: readonly MissionLifecycleEvidence[],
): MissionReadModel["timeline"] {
  return events
    .map((event, sourceIndex) => ({
      event,
      sourceIndex,
    }))
    .sort((left, right) => {
      const timestampOrder = left.event.persisted_at.localeCompare(
        right.event.persisted_at,
      );

      return timestampOrder !== 0
        ? timestampOrder
        : left.sourceIndex - right.sourceIndex;
    })
    .map(({ event }) => ({
      event_type: event.transition_authorization,
      timestamp: event.persisted_at,
    }));
}

export function assembleMissionReadModel(
  input: MissionAssemblyInput,
): MissionReadModel {
  const stage = deriveStage(input);

  const owner: MissionOwner =
    stage === "ASSIGNED"
      ? "DEPARTMENT"
      : "UNKNOWN";

  const health: MissionHealth =
    input.integrity_warnings?.length
      ? "NEEDS_ATTENTION"
      : "HEALTHY";

  return {
    identity: {
      package_id: input.package_id,
      package_version: input.package_version,
      project_id: input.project_id,
    },

    stage,

    owner,

    health,

    awaiting: null,

    evidence: {
      artifact_count: 0,
      lifecycle_event_count: input.lifecycle_event_count,
      integrity_warnings: [...(input.integrity_warnings ?? [])],
      latest_timestamp: null,
    },

    timeline: assembleTimeline(input.lifecycle_events ?? []),
  };
}
