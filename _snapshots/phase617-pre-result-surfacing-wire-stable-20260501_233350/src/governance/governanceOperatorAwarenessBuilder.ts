/**
 * Phase 131.1 — Governance Operator Awareness Builder
 * Pure read-only awareness signal construction.
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
  buildGovernanceOutcomeSurface
} from "./governanceOutcomeSurfaceBuilder";

import {
  GovernanceExecutionRoutingInput
} from "./governanceExecutionRouting";

import {
  GovernanceOperatorAwarenessSignal,
  mapGovernanceAwarenessSeverity
} from "./governanceOperatorAwarenessTypes";

export function buildGovernanceOperatorAwarenessSignal(
  input: GovernanceExecutionRoutingInput
): GovernanceOperatorAwarenessSignal {
  const surface =
    buildGovernanceOutcomeSurface(input);

  const severity =
    mapGovernanceAwarenessSeverity(surface.surfaceLevel);

  return {
    outcome: surface.outcome,
    destination: surface.destination,
    confidence: surface.confidence,
    surfaceLevel: surface.surfaceLevel,
    severity,
    operatorVisible: true,
    readonly: true,
    deterministic: true,
    reason: surface.reason
  };
}
