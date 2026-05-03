/**
 * Phase 138 — Governance Runtime Registry Export
 *
 * Deterministic runtime-registry-facing export surface for governance
 * dashboard contract registrations.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceDashboardContractRegistration } from "./governance_dashboard_contract_registration";

export interface GovernanceRuntimeRegistryExport {
  readonly kind: "governance-runtime-registry-export";
  readonly version: 1;

  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly registration: GovernanceDashboardContractRegistration;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
