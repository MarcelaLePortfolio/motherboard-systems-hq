/**
 * Phase 137 — Governance Dashboard Contract Registration Normalization
 *
 * Defensive deterministic normalization for registry-facing registration.
 */

import type { GovernanceDashboardContractRegistration } from "./governance_dashboard_contract_registration";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function normalizeGovernanceDashboardContractRegistration(
  registration: GovernanceDashboardContractRegistration
): GovernanceDashboardContractRegistration {
  return Object.freeze({
    ...registration,
    payload: Object.freeze({
      ...registration.payload,
      signals: uniqueSorted(registration.payload.signals),
      signalCount: uniqueSorted(registration.payload.signals).length,
      operatorSafe: true as const,
      dashboardSafe: true as const,
      readOnly: true as const,
      deterministic: true as const
    }),
    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
