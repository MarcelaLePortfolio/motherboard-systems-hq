/**
 * Phase 141 — Governance Explicit Live Wiring Decision Selector
 *
 * Read-only deterministic decision selection surface.
 */

import type { GovernanceLiveWiringDecision } from "./governance_live_wiring_decision";

export interface GovernanceLiveWiringDecisionSelection {
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly decisionStatus: "eligible" | "ineligible";
  readonly eligibleForExplicitLiveWiring: boolean;
  readonly decisionReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceLiveWiringDecision(
  decision: GovernanceLiveWiringDecision
): GovernanceLiveWiringDecisionSelection {
  return Object.freeze({
    decisionKey: decision.decisionKey,
    readinessKey: decision.readinessKey,
    ownerKey: decision.ownerKey,
    exportKey: decision.exportKey,
    registryKey: decision.registryKey,
    contractId: decision.contractId,
    decisionStatus: decision.decisionStatus,
    eligibleForExplicitLiveWiring: decision.eligibleForExplicitLiveWiring,
    decisionReasonCount: decision.decisionReasons.length,
    signalCount: decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
