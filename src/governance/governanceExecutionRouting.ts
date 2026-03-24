/**
 * Phase 129 — Governance Execution Routing
 * Deterministic routing surface for governance outcomes.
 *
 * NON-GOALS:
 * - No execution coupling
 * - No async behavior
 * - No UI interaction
 * - No authority expansion
 */

export type GovernanceOutcomeType =
  | "ALLOW"
  | "DENY"
  | "REVIEW"
  | "ESCALATE"
  | "INFORM";

export type GovernanceAuthorityDestination =
  | "OPERATOR"
  | "GOVERNANCE_LOG"
  | "VALIDATION_VIEW"
  | "READONLY_OPERATOR_VIEW";

export interface GovernanceExecutionRoutingResult {
  outcome: GovernanceOutcomeType;
  destination: GovernanceAuthorityDestination;
  reason: string;
  deterministic: true;
}

export interface GovernanceExecutionRoutingInput {
  outcome: GovernanceOutcomeType;
  reason: string;
}

/**
 * Deterministic routing classifier.
 * Pure function.
 * No side effects.
 */
export function routeGovernanceOutcome(
  input: GovernanceExecutionRoutingInput
): GovernanceExecutionRoutingResult {
  switch (input.outcome) {
    case "ALLOW":
      return {
        outcome: "ALLOW",
        destination: "GOVERNANCE_LOG",
        reason: input.reason,
        deterministic: true
      };

    case "DENY":
      return {
        outcome: "DENY",
        destination: "VALIDATION_VIEW",
        reason: input.reason,
        deterministic: true
      };

    case "REVIEW":
      return {
        outcome: "REVIEW",
        destination: "READONLY_OPERATOR_VIEW",
        reason: input.reason,
        deterministic: true
      };

    case "ESCALATE":
      return {
        outcome: "ESCALATE",
        destination: "OPERATOR",
        reason: input.reason,
        deterministic: true
      };

    case "INFORM":
      return {
        outcome: "INFORM",
        destination: "GOVERNANCE_LOG",
        reason: input.reason,
        deterministic: true
      };

    default: {
      const _exhaustiveCheck: never = input.outcome;
      throw new Error("Unknown governance outcome");
    }
  }
}
