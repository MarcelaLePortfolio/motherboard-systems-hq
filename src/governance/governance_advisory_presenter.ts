/*
Phase 292 — Governance Advisory Presentation Layer

Purpose:
Provide deterministic formatting structures for operator-readable
governance advisory output.

SAFETY:

Read-only
Pure formatting layer
No runtime wiring
No reducers
No execution interaction
No mutation capability
*/

import {
  GovernanceAdvisorySignal,
  GovernanceSeverity
} from "./governance_advisory_contract";

export interface GovernancePresentationGroup {

  severity: GovernanceSeverity;

  signals: GovernanceAdvisorySignal[];

  count: number;

}

export interface GovernancePresentationReport {

  generated_at: string;

  groups: GovernancePresentationGroup[];

  total_signals: number;

}

const severityOrder: GovernanceSeverity[] = [
  "critical",
  "risk",
  "warning",
  "notice",
  "info"
];

export function groupSignalsBySeverity(
  signals: GovernanceAdvisorySignal[]
): GovernancePresentationGroup[] {

  const map = new Map<GovernanceSeverity, GovernanceAdvisorySignal[]>();

  for (const severity of severityOrder) {
    map.set(severity, []);
  }

  for (const signal of signals) {

    const bucket = map.get(signal.severity);

    if (bucket) {
      bucket.push(signal);
    }

  }

  const groups: GovernancePresentationGroup[] = [];

  for (const severity of severityOrder) {

    const bucket = map.get(severity)!;

    if (bucket.length === 0) {
      continue;
    }

    groups.push({

      severity,

      signals: bucket,

      count: bucket.length

    });

  }

  return groups;

}

export function buildGovernancePresentation(
  signals: GovernanceAdvisorySignal[]
): GovernancePresentationReport {

  const groups = groupSignalsBySeverity(signals);

  return {

    generated_at: new Date().toISOString(),

    groups,

    total_signals: signals.length

  };

}
