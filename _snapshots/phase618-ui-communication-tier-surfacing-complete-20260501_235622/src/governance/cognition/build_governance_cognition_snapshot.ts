/**
 * Phase 135 — Governance Cognition Snapshot Builder
 *
 * Deterministic builder.
 * Pure function.
 * No side effects.
 */

import type {
  GovernanceCognitionSnapshot,
  GovernanceCognitionSeverity,
  GovernanceCognitionStatus
} from "./governance_cognition_snapshot_contract";

export interface GovernanceCognitionBuilderInput {
  readonly routingStatus: GovernanceCognitionStatus;
  readonly authorityStatus: GovernanceCognitionStatus;
  readonly registryStatus: GovernanceCognitionStatus;

  readonly signals: readonly string[];
  readonly ts: number;
}

function deriveSeverity(
  routing: GovernanceCognitionStatus,
  authority: GovernanceCognitionStatus,
  registry: GovernanceCognitionStatus
): GovernanceCognitionSeverity {

  const states = [routing, authority, registry];

  if (states.includes("blocked")) return "critical";
  if (states.includes("review")) return "elevated";
  if (states.includes("attention")) return "warning";

  return "info";
}

function deriveOverall(
  routing: GovernanceCognitionStatus,
  authority: GovernanceCognitionStatus,
  registry: GovernanceCognitionStatus
): GovernanceCognitionStatus {

  const states = [routing, authority, registry];

  if (states.includes("blocked")) return "blocked";
  if (states.includes("review")) return "review";
  if (states.includes("attention")) return "attention";

  return "stable";
}

export function buildGovernanceCognitionSnapshot(
  input: GovernanceCognitionBuilderInput
): GovernanceCognitionSnapshot {

  const severity = deriveSeverity(
    input.routingStatus,
    input.authorityStatus,
    input.registryStatus
  );

  const overall = deriveOverall(
    input.routingStatus,
    input.authorityStatus,
    input.registryStatus
  );

  return Object.freeze({
    ts: input.ts,

    routingStatus: input.routingStatus,
    authorityStatus: input.authorityStatus,
    registryStatus: input.registryStatus,

    overallStatus: overall,
    severity,

    signals: Object.freeze([...input.signals]),

    deterministic: true as const
  });
}
