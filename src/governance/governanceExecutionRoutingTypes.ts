/**
 * Phase 129.1 — Governance Execution Routing Types Expansion
 * Separates routing result structure for future deterministic extensions.
 */

import {
  GovernanceOutcomeType,
  GovernanceAuthorityDestination
} from "./governanceExecutionRouting";

export type GovernanceRoutingConfidence =
  | "HIGH"
  | "MEDIUM"
  | "LOW";

export interface GovernanceRoutingClassification {
  outcome: GovernanceOutcomeType;
  destination: GovernanceAuthorityDestination;
  confidence: GovernanceRoutingConfidence;
  reason: string;
  deterministic: true;
}

export function classifyRoutingConfidence(
  outcome: GovernanceOutcomeType
): GovernanceRoutingConfidence {

  switch (outcome) {

    case "ALLOW":
      return "HIGH";

    case "DENY":
      return "HIGH";

    case "ESCALATE":
      return "HIGH";

    case "REVIEW":
      return "MEDIUM";

    case "INFORM":
      return "LOW";

    default: {
      const _never: never = outcome;
      return _never;
    }
  }
}

