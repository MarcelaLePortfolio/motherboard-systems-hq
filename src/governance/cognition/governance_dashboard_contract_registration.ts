/**
 * Phase 137 — Governance Dashboard Contract Registration
 *
 * Formal contract-level registration surface for governance dashboard
 * consumption views within the cognition transport / consumption discipline.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 */

import type { GovernanceDashboardConsumptionView } from "./governance_dashboard_consumption_contract";

export interface GovernanceDashboardContractRegistration {
  readonly kind: "governance-dashboard-contract-registration";
  readonly version: 1;

  readonly contractId: "governance.dashboard.consumption";
  readonly registryKey: "governance-dashboard-consumption";
  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly payload: GovernanceDashboardConsumptionView;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
