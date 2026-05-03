/**
 * Phase 142 — Governance Authorization Gate Preparation
 *
 * Deterministic authorization gate surface defining the conditions required
 * before any future explicitly authorized live runtime registry owner wiring
 * can occur, without performing that wiring.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceLiveWiringDecision } from "./governance_live_wiring_decision";

export type GovernanceAuthorizationGateStatus =
  | "open"
  | "closed";

export interface GovernanceAuthorizationGate {
  readonly kind: "governance-authorization-gate";
  readonly version: 1;

  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly gateStatus: GovernanceAuthorizationGateStatus;
  readonly authorizationEligible: boolean;
  readonly authorizationReasons: readonly string[];

  readonly decision: GovernanceLiveWiringDecision;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
