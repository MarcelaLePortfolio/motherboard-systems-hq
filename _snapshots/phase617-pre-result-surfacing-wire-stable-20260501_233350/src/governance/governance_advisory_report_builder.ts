/*
Phase 290 — Governance Advisory Layer Planning (Part 2)

Governance Advisory Report Builder

Purpose:
Pure deterministic builder for GovernanceAdvisoryReport.
Transforms advisory signals into a structured report.

SAFETY:

Read-only
Pure function
No runtime coupling
No execution wiring
No reducers
No side effects
*/

import {
  GovernanceAdvisorySignal,
  GovernanceAdvisoryReport,
  deriveHighestSeverity
} from "./governance_advisory_contract";

export function buildGovernanceAdvisoryReport(
  signals: GovernanceAdvisorySignal[]
): GovernanceAdvisoryReport {

  const safeSignals = signals ?? [];

  return {

    generated_at: new Date().toISOString(),

    signals: safeSignals,

    total_signals: safeSignals.length,

    highest_severity: deriveHighestSeverity(safeSignals)

  };

}
