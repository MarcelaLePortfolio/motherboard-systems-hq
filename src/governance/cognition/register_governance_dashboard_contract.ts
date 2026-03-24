/**
 * Phase 137 — Governance Dashboard Contract Registration Builder
 *
 * Pure deterministic registration adapter.
 */

import type { GovernanceDashboardConsumptionView } from "./governance_dashboard_consumption_contract";
import type { GovernanceDashboardContractRegistration } from "./governance_dashboard_contract_registration";

export function registerGovernanceDashboardContract(
  payload: GovernanceDashboardConsumptionView
): GovernanceDashboardContractRegistration {
  return Object.freeze({
    kind: "governance-dashboard-contract-registration" as const,
    version: 1 as const,

    contractId: "governance.dashboard.consumption" as const,
    registryKey: "governance-dashboard-consumption" as const,
    channel: "dashboard" as const,
    surface: "governance" as const,
    mode: "read-only" as const,

    ts: payload.ts,

    payload,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
