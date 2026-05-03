/**
 * Phase 142 — Governance Authorization Gate Selector
 *
 * Read-only deterministic authorization selection surface.
 */

import type { GovernanceAuthorizationGate } from "./governance_authorization_gate";

export interface GovernanceAuthorizationGateSelection {
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly gateStatus: "open" | "closed";
  readonly authorizationEligible: boolean;
  readonly authorizationReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceAuthorizationGate(
  gate: GovernanceAuthorizationGate
): GovernanceAuthorizationGateSelection {
  return Object.freeze({
    gateKey: gate.gateKey,
    decisionKey: gate.decisionKey,
    readinessKey: gate.readinessKey,
    ownerKey: gate.ownerKey,
    exportKey: gate.exportKey,
    registryKey: gate.registryKey,
    contractId: gate.contractId,
    gateStatus: gate.gateStatus,
    authorizationEligible: gate.authorizationEligible,
    authorizationReasonCount: gate.authorizationReasons.length,
    signalCount: gate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
