/**
 * Phase 134.0 — Governance Cognition Integration Hooks
 * Read-only integration hook layer for safe downstream cognition consumption.
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
  GovernanceCognitionSurface
} from "./governanceCognitionSurfaceTypes";

import {
  selectGovernanceCognitionStatus,
  selectGovernanceCognitionHighestSeverity,
  selectGovernanceCognitionSignalCount,
  selectGovernanceCognitionCriticalSignalCount,
  selectGovernanceCognitionReviewSignalCount,
  selectGovernanceCognitionInformationalSignalCount
} from "./governanceCognitionSelectors";

export interface GovernanceCognitionIntegrationHooks {
  getStatus: () => GovernanceCognitionSurface["status"];
  getHighestSeverity: () => GovernanceCognitionSurface["highestSeverity"];
  getSignalCount: () => number;
  getCriticalSignalCount: () => number;
  getReviewSignalCount: () => number;
  getInformationalSignalCount: () => number;
  readonly: true;
  deterministic: true;
}

export function createGovernanceCognitionIntegrationHooks(
  surface: GovernanceCognitionSurface
): GovernanceCognitionIntegrationHooks {
  return {
    getStatus: () => selectGovernanceCognitionStatus(surface),
    getHighestSeverity: () => selectGovernanceCognitionHighestSeverity(surface),
    getSignalCount: () => selectGovernanceCognitionSignalCount(surface),
    getCriticalSignalCount: () =>
      selectGovernanceCognitionCriticalSignalCount(surface),
    getReviewSignalCount: () =>
      selectGovernanceCognitionReviewSignalCount(surface),
    getInformationalSignalCount: () =>
      selectGovernanceCognitionInformationalSignalCount(surface),
    readonly: true,
    deterministic: true
  };
}
