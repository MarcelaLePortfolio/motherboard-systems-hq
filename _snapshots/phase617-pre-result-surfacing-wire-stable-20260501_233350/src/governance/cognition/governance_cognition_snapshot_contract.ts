/**
 * Phase 135 — Governance Cognition Snapshot Contract
 *
 * Deterministic snapshot representation of governance cognition state.
 * No runtime mutation.
 * No execution coupling.
 * No UI coupling.
 */

export type GovernanceCognitionSeverity =
  | "info"
  | "notice"
  | "warning"
  | "elevated"
  | "critical";

export type GovernanceCognitionStatus =
  | "stable"
  | "attention"
  | "review"
  | "action-safe"
  | "blocked";

export interface GovernanceCognitionSnapshot {
  readonly ts: number;

  readonly routingStatus: GovernanceCognitionStatus;
  readonly authorityStatus: GovernanceCognitionStatus;
  readonly registryStatus: GovernanceCognitionStatus;

  readonly overallStatus: GovernanceCognitionStatus;
  readonly severity: GovernanceCognitionSeverity;

  readonly signals: readonly string[];

  readonly deterministic: true;
}
