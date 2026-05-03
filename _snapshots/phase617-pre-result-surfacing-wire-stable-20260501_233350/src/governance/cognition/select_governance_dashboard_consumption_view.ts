/**
 * Phase 136 — Governance Dashboard Consumption Selector
 *
 * Read-only deterministic selector surface.
 */

import type { GovernanceDashboardConsumptionView } from "./governance_dashboard_consumption_contract";

export interface GovernanceDashboardConsumptionSelection {
  readonly headlineStatus: GovernanceDashboardConsumptionView["overallStatus"];
  readonly headlineSeverity: GovernanceDashboardConsumptionView["severity"];
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceDashboardConsumptionView(
  view: GovernanceDashboardConsumptionView
): GovernanceDashboardConsumptionSelection {
  return Object.freeze({
    headlineStatus: view.overallStatus,
    headlineSeverity: view.severity,
    signalCount: view.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
