/**
 * Phase 130.0 — Governance Outcome Surface Types
 * Read-only cognition exposure layer.
 *
 * NON-GOALS:
 * No execution behavior
 * No routing changes
 * No UI coupling
 * No authority expansion
 */

import {
  GovernanceOutcomeType,
  GovernanceAuthorityDestination
} from "./governanceExecutionRouting";

import {
  GovernanceRoutingConfidence
} from "./governanceExecutionRoutingTypes";

export type GovernanceOutcomeSurfaceLevel =
  | "INFO"
  | "ATTENTION"
  | "REVIEW"
  | "CRITICAL";

export interface GovernanceOutcomeSurface {
  outcome: GovernanceOutcomeType;
  destination: GovernanceAuthorityDestination;
  confidence: GovernanceRoutingConfidence;

  surfaceLevel: GovernanceOutcomeSurfaceLevel;

  operatorVisible: true;
  readonly: true;
  deterministic: true;

  reason: string;
}

export function mapOutcomeSurfaceLevel(
  outcome: GovernanceOutcomeType
): GovernanceOutcomeSurfaceLevel {

  switch (outcome) {

    case "ALLOW":
      return "INFO";

    case "INFORM":
      return "INFO";

    case "REVIEW":
      return "ATTENTION";

    case "DENY":
      return "REVIEW";

    case "ESCALATE":
      return "CRITICAL";

    default: {
      const _never: never = outcome;
      return _never;
    }

  }

}

