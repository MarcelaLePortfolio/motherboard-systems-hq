/**
 * Phase 144 — Governance Pre-Live Registry Handoff Envelope Selector
 *
 * Read-only deterministic handoff envelope selection surface.
 */

import type { GovernancePreLiveRegistryHandoffEnvelope } from "./governance_pre_live_registry_handoff_envelope";

export interface GovernancePreLiveRegistryHandoffEnvelopeSelection {
  readonly envelopeKey: "governance-pre-live-registry-handoff-envelope";
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly envelopeStatus: "wrapped";
  readonly handoffReady: boolean;
  readonly envelopeReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernancePreLiveRegistryHandoffEnvelope(
  envelope: GovernancePreLiveRegistryHandoffEnvelope
): GovernancePreLiveRegistryHandoffEnvelopeSelection {
  return Object.freeze({
    envelopeKey: envelope.envelopeKey,
    packageKey: envelope.packageKey,
    gateKey: envelope.gateKey,
    decisionKey: envelope.decisionKey,
    readinessKey: envelope.readinessKey,
    ownerKey: envelope.ownerKey,
    exportKey: envelope.exportKey,
    registryKey: envelope.registryKey,
    contractId: envelope.contractId,
    envelopeStatus: envelope.envelopeStatus,
    handoffReady: envelope.handoffReady,
    envelopeReasonCount: envelope.envelopeReasons.length,
    signalCount: envelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
