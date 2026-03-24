/**
 * Phase 136 — Governance Dashboard Consumption View Builder
 *
 * Pure read-only adapter from operator-safe snapshot package
 * to dashboard-safe consumption view.
 */

import type { OperatorSafeGovernanceCognitionPackage } from "./package_governance_cognition_snapshot";
import type { GovernanceDashboardConsumptionView } from "./governance_dashboard_consumption_contract";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceDashboardConsumptionView(
  input: OperatorSafeGovernanceCognitionPackage
): GovernanceDashboardConsumptionView {
  const snapshot = input.snapshot;
  const signals = uniqueSorted(snapshot.signals);

  return Object.freeze({
    kind: "governance-dashboard-consumption-view" as const,
    version: 1 as const,

    ts: snapshot.ts,

    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,

    routingStatus: snapshot.routingStatus,
    authorityStatus: snapshot.authorityStatus,
    registryStatus: snapshot.registryStatus,

    signalCount: signals.length,
    signals,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
