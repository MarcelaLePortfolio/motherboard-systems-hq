/**
 * Phase 132.1 — Governance Cognition Surface Builder
 * Deterministic cognition surface construction.
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
  GovernanceOperatorAwarenessSignal,
  GovernanceAwarenessSeverity
} from "./governanceOperatorAwarenessTypes";

import {
  summarizeGovernanceOperatorAwareness
} from "./governanceOperatorAwarenessSummary";

import {
  GovernanceCognitionSurface,
  mapGovernanceCognitionSurfaceStatus
} from "./governanceCognitionSurfaceTypes";

function getHighestSeverity(
  signals: GovernanceOperatorAwarenessSignal[]
): GovernanceAwarenessSeverity {
  let highest: GovernanceAwarenessSeverity = "LOW";

  for (const signal of signals) {
    if (signal.severity === "CRITICAL") {
      return "CRITICAL";
    }

    if (signal.severity === "HIGH" && highest !== "CRITICAL") {
      highest = "HIGH";
      continue;
    }

    if (
      signal.severity === "ELEVATED" &&
      highest !== "CRITICAL" &&
      highest !== "HIGH"
    ) {
      highest = "ELEVATED";
    }
  }

  return highest;
}

export function buildGovernanceCognitionSurface(
  signals: GovernanceOperatorAwarenessSignal[]
): GovernanceCognitionSurface {
  const summary =
    summarizeGovernanceOperatorAwareness(signals);

  const highestSeverity =
    getHighestSeverity(signals);

  const status =
    mapGovernanceCognitionSurfaceStatus(highestSeverity);

  return {
    status,
    signals,
    summary,
    highestSeverity,
    operatorVisible: true,
    readonly: true,
    deterministic: true
  };
}
