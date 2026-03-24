/**
 * Phase 141 — Governance Explicit Live Wiring Decision Surface
 *
 * Deterministic decision surface formalizing whether governance cognition
 * is eligible for future explicitly authorized live runtime registry owner
 * wiring, without performing that wiring.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceLiveRegistryWiringReadiness } from "./governance_live_registry_wiring_readiness";

export type GovernanceLiveWiringDecisionStatus =
  | "eligible"
  | "ineligible";

export interface GovernanceLiveWiringDecision {
  readonly kind: "governance-live-wiring-decision";
  readonly version: 1;

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

  readonly decisionStatus: GovernanceLiveWiringDecisionStatus;
  readonly eligibleForExplicitLiveWiring: boolean;
  readonly decisionReasons: readonly string[];

  readonly readiness: GovernanceLiveRegistryWiringReadiness;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
