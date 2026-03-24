/**
 * Phase 131.0 — Governance Operator Awareness Types
 * Read-only operator cognition awareness layer.
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
  GovernanceOutcomeType,
  GovernanceAuthorityDestination
} from "./governanceExecutionRouting";

import {
  GovernanceRoutingConfidence
} from "./governanceExecutionRoutingTypes";

import {
  GovernanceOutcomeSurfaceLevel
} from "./governanceOutcomeSurfaceTypes";

export type GovernanceAwarenessSeverity =
  | "LOW"
  | "ELEVATED"
  | "HIGH"
  | "CRITICAL";

export interface GovernanceOperatorAwarenessSignal {
  outcome: GovernanceOutcomeType;
  destination: GovernanceAuthorityDestination;
  confidence: GovernanceRoutingConfidence;
  surfaceLevel: GovernanceOutcomeSurfaceLevel;
  severity: GovernanceAwarenessSeverity;
  operatorVisible: true;
  readonly: true;
  deterministic: true;
  reason: string;
}

export interface GovernanceOperatorAwarenessSummary {
  totalSignals: number;
  criticalSignals: number;
  reviewSignals: number;
  informationalSignals: number;
  readonly: true;
  deterministic: true;
}

export function mapGovernanceAwarenessSeverity(
  surfaceLevel: GovernanceOutcomeSurfaceLevel
): GovernanceAwarenessSeverity {
  switch (surfaceLevel) {
    case "INFO":
      return "LOW";

    case "ATTENTION":
      return "ELEVATED";

    case "REVIEW":
      return "HIGH";

    case "CRITICAL":
      return "CRITICAL";

    default: {
      const _never: never = surfaceLevel;
      return _never;
    }
  }
}
