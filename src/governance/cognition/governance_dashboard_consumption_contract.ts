/**
 * Phase 136 — Governance Dashboard Consumption Contract
 *
 * Read-only dashboard-safe governance cognition consumption surface.
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 */

import type {
  GovernanceCognitionSeverity,
  GovernanceCognitionStatus
} from "./governance_cognition_snapshot_contract";

export interface GovernanceDashboardConsumptionView {
  readonly kind: "governance-dashboard-consumption-view";
  readonly version: 1;

  readonly ts: number;

  readonly overallStatus: GovernanceCognitionStatus;
  readonly severity: GovernanceCognitionSeverity;

  readonly routingStatus: GovernanceCognitionStatus;
  readonly authorityStatus: GovernanceCognitionStatus;
  readonly registryStatus: GovernanceCognitionStatus;

  readonly signalCount: number;
  readonly signals: readonly string[];

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
