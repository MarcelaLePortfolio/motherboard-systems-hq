/**
 * Phase 130.1 — Governance Outcome Surface Builder
 * Deterministic cognition exposure construction.
 *
 * NON-GOALS:
 * No execution behavior
 * No routing mutation
 * No UI interaction
 * No authority expansion
 */

import {
  classifyGovernanceRouting
} from "./governanceExecutionRoutingClassifier";

import {
  GovernanceExecutionRoutingInput
} from "./governanceExecutionRouting";

import {
  GovernanceOutcomeSurface,
  mapOutcomeSurfaceLevel
} from "./governanceOutcomeSurfaceTypes";

export function buildGovernanceOutcomeSurface(
  input: GovernanceExecutionRoutingInput
): GovernanceOutcomeSurface {

  const routing =
    classifyGovernanceRouting(input);

  const surfaceLevel =
    mapOutcomeSurfaceLevel(routing.outcome);

  return {

    outcome: routing.outcome,
    destination: routing.destination,
    confidence: routing.confidence,

    surfaceLevel,

    operatorVisible: true,
    readonly: true,
    deterministic: true,

    reason: routing.reason

  };

}

