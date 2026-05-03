/**
 * Phase 129.2 — Governance Execution Routing Classifier
 * Deterministic composition layer combining routing + confidence.
 *
 * NON-GOALS:
 * No execution behavior
 * No side effects
 * No authority expansion
 */

import {
  routeGovernanceOutcome,
  GovernanceExecutionRoutingInput,
  GovernanceExecutionRoutingResult
} from "./governanceExecutionRouting";

import {
  classifyRoutingConfidence,
  GovernanceRoutingClassification
} from "./governanceExecutionRoutingTypes";

export function classifyGovernanceRouting(
  input: GovernanceExecutionRoutingInput
): GovernanceRoutingClassification {

  const routing: GovernanceExecutionRoutingResult =
    routeGovernanceOutcome(input);

  const confidence =
    classifyRoutingConfidence(routing.outcome);

  return {
    outcome: routing.outcome,
    destination: routing.destination,
    confidence,
    reason: routing.reason,
    deterministic: true
  };
}

