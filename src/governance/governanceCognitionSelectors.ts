/**
 * Phase 133.0 — Governance Cognition Selectors
 * Read-only selector layer for dashboard-safe governance cognition consumption.
 *
 * NON-GOALS:
 * No UI rendering
 * No DOM interaction
 * No reducer mutation
 * No telemetry mutation
 * No execution coupling
 * No authority expansion
 */

import {
  GovernanceCognitionSurface,
  GovernanceCognitionSurfaceStatus
} from "./governanceCognitionSurfaceTypes";

import {
  GovernanceOperatorAwarenessSignal,
  GovernanceAwarenessSeverity
} from "./governanceOperatorAwarenessTypes";

export function selectGovernanceCognitionStatus(
  surface: GovernanceCognitionSurface
): GovernanceCognitionSurfaceStatus {
  return surface.status;
}

export function selectGovernanceCognitionSignals(
  surface: GovernanceCognitionSurface
): GovernanceOperatorAwarenessSignal[] {
  return surface.signals;
}

export function selectGovernanceCognitionHighestSeverity(
  surface: GovernanceCognitionSurface
): GovernanceAwarenessSeverity {
  return surface.highestSeverity;
}

export function selectGovernanceCognitionSignalCount(
  surface: GovernanceCognitionSurface
): number {
  return surface.summary.totalSignals;
}

export function selectGovernanceCognitionCriticalSignalCount(
  surface: GovernanceCognitionSurface
): number {
  return surface.summary.criticalSignals;
}

export function selectGovernanceCognitionReviewSignalCount(
  surface: GovernanceCognitionSurface
): number {
  return surface.summary.reviewSignals;
}

export function selectGovernanceCognitionInformationalSignalCount(
  surface: GovernanceCognitionSurface
): number {
  return surface.summary.informationalSignals;
}
