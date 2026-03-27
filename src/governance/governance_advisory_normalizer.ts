/*
Phase 291 — Governance Advisory Normalization Layer

Purpose:
Normalize governance advisory signals for deterministic ordering,
deduplication, and stable reporting structure.

SAFETY:

Read-only
Pure function
Deterministic
No runtime wiring
No execution coupling
No reducers
No mutation of source signals
*/

import { GovernanceAdvisorySignal } from "./governance_advisory_contract";

function buildSignalKey(signal: GovernanceAdvisorySignal): string {
  return [
    signal.domain,
    signal.severity,
    signal.summary,
    signal.source,
    signal.detected_at
  ].join("|");
}

export function normalizeGovernanceSignals(
  signals: GovernanceAdvisorySignal[]
): GovernanceAdvisorySignal[] {

  const seen = new Set<string>();

  const deduped: GovernanceAdvisorySignal[] = [];

  for (const signal of signals) {

    const key = buildSignalKey(signal);

    if (seen.has(key)) {
      continue;
    }

    seen.add(key);

    deduped.push(signal);

  }

  return deduped.sort((a,b) => {

    if (a.severity === b.severity) {
      return a.detected_at.localeCompare(b.detected_at);
    }

    const order = [
      "info",
      "notice",
      "warning",
      "risk",
      "critical"
    ];

    return order.indexOf(a.severity) - order.indexOf(b.severity);

  });

}
