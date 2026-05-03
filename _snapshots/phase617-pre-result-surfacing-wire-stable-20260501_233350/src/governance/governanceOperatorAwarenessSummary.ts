/**
 * Phase 131.2 — Governance Operator Awareness Summary
 * Deterministic aggregation for read-only operator cognition signals.
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
  GovernanceOperatorAwarenessSummary
} from "./governanceOperatorAwarenessTypes";

export function summarizeGovernanceOperatorAwareness(
  signals: GovernanceOperatorAwarenessSignal[]
): GovernanceOperatorAwarenessSummary {
  let criticalSignals = 0;
  let reviewSignals = 0;
  let informationalSignals = 0;

  for (const signal of signals) {
    if (signal.surfaceLevel === "CRITICAL") {
      criticalSignals += 1;
      continue;
    }

    if (signal.surfaceLevel === "REVIEW" || signal.surfaceLevel === "ATTENTION") {
      reviewSignals += 1;
      continue;
    }

    informationalSignals += 1;
  }

  return {
    totalSignals: signals.length,
    criticalSignals,
    reviewSignals,
    informationalSignals,
    readonly: true,
    deterministic: true
  };
}
