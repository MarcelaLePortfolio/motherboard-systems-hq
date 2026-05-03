/**
 * Phase 132.0 — Governance Cognition Surface Types
 * Dashboard-ready read-only cognition data contract.
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
  GovernanceAwarenessSeverity,
  GovernanceOperatorAwarenessSignal,
  GovernanceOperatorAwarenessSummary
} from "./governanceOperatorAwarenessTypes";

export type GovernanceCognitionSurfaceStatus =
  | "STABLE"
  | "ELEVATED"
  | "REVIEW"
  | "CRITICAL";

export interface GovernanceCognitionSurface {
  status: GovernanceCognitionSurfaceStatus;
  signals: GovernanceOperatorAwarenessSignal[];
  summary: GovernanceOperatorAwarenessSummary;
  highestSeverity: GovernanceAwarenessSeverity;
  operatorVisible: true;
  readonly: true;
  deterministic: true;
}

export function mapGovernanceCognitionSurfaceStatus(
  highestSeverity: GovernanceAwarenessSeverity
): GovernanceCognitionSurfaceStatus {
  switch (highestSeverity) {
    case "LOW":
      return "STABLE";

    case "ELEVATED":
      return "ELEVATED";

    case "HIGH":
      return "REVIEW";

    case "CRITICAL":
      return "CRITICAL";

    default: {
      const _never: never = highestSeverity;
      return _never;
    }
  }
}
