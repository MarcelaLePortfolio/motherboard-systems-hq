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
  conversation_id: string | null;
  requested_outcome: string;

  authorization_state: string | null;
  validation_status: string | null;
  gate_status: string | null;
  lifecycle_state: string | null;

  lifecycle_event_count: number;
  lifecycle_events?: readonly MissionLifecycleEvidence[];

  integrity_warnings?: readonly string[];
}

function deriveStage(input: MissionAssemblyInput): MissionStage {
  if (input.lifecycle_state === "ASSIGNED") {
    return input.lifecycle_event_count > 0 ? "ASSIGNED" : "UNKNOWN";
  }

  if (input.lifecycle_state === "ENVELOPE_CREATED") {
    return "ENVELOPE_CREATED";
  }

  if (input.gate_status === "OPEN") {
    return "ENVELOPE_GATE";
  }

  if (input.validation_status === "VALIDATION_PASSED") {
    return "ENVELOPE_GATE";
  }

  if (input.authorization_state === "AUTHORIZED") {
    return "GOVERNANCE_VALIDATION";
  }

  if (
    input.authorization_state === null &&
    input.validation_status === null &&
    input.gate_status === null &&
    input.lifecycle_state === null
  ) {
    return "AWAITING_DELEGATION";
  }

  return "UNKNOWN";
}

function deriveIntegrityWarnings(
  input: MissionAssemblyInput,
): string[] {
  const warnings = [...(input.integrity_warnings ?? [])];

  if (
    input.validation_status !== null &&
    input.authorization_state !== "AUTHORIZED"
  ) {
    warnings.push(
      "Validation state exists without an authorized delegation.",
    );
  }

  if (
    input.gate_status !== null &&
    input.validation_status !== "VALIDATION_PASSED"
  ) {
    warnings.push(
      "Envelope gate state exists without passed governance validation.",
    );
  }

  if (
    input.lifecycle_state !== null &&
    input.lifecycle_state !== "ASSIGNED" &&
    input.gate_status !== "OPEN" &&
    input.gate_status !== "PASSED"
  ) {
    warnings.push(
      "Envelope lifecycle state exists without authoritative envelope-gate lineage.",
    );
  }

  return warnings;
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
  const integrityWarnings = deriveIntegrityWarnings(input);

  const owner: MissionOwner =
    stage === "AWAITING_DELEGATION"
      ? "UNASSIGNED"
      : stage === "GOVERNANCE_VALIDATION" ||
          stage === "ENVELOPE_GATE" ||
          stage === "ENVELOPE_CREATED"
        ? "GOVERNANCE"
        : stage === "ASSIGNED"
          ? "DEPARTMENT"
          : "UNKNOWN";

  const health: MissionHealth =
    integrityWarnings.length > 0
      ? "NEEDS_ATTENTION"
      : stage === "AWAITING_DELEGATION"
        ? "WAITING"
        : "HEALTHY";

  const awaiting =
    stage === "AWAITING_DELEGATION"
      ? "Delegation authorization"
      : stage === "GOVERNANCE_VALIDATION"
        ? "Governance validation"
        : stage === "ENVELOPE_GATE"
          ? "Envelope creation"
          : null;

  return {
    identity: {
      package_id: input.package_id,
      package_version: input.package_version,
      project_id: input.project_id,
      conversation_id: input.conversation_id,
    },

    requested_outcome: input.requested_outcome,

    stage,

    owner,

    health,

    awaiting,

    evidence: {
      artifact_count: 0,
      lifecycle_event_count: input.lifecycle_event_count,
      integrity_warnings: integrityWarnings,
      latest_timestamp: null,
    },

    timeline: assembleTimeline(input.lifecycle_events ?? []),
  };
}
