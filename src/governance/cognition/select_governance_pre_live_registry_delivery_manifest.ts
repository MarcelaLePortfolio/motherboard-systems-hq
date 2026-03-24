/**
 * Phase 145 — Governance Pre-Live Registry Delivery Manifest Selector
 *
 * Read-only deterministic delivery manifest selection surface.
 */

import type { GovernancePreLiveRegistryDeliveryManifest } from "./governance_pre_live_registry_delivery_manifest";

export interface GovernancePreLiveRegistryDeliveryManifestSelection {
  readonly manifestKey: "governance-pre-live-registry-delivery-manifest";
  readonly envelopeKey: "governance-pre-live-registry-handoff-envelope";
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly manifestStatus: "prepared";
  readonly deliveryReady: boolean;
  readonly manifestReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernancePreLiveRegistryDeliveryManifest(
  manifest: GovernancePreLiveRegistryDeliveryManifest
): GovernancePreLiveRegistryDeliveryManifestSelection {
  return Object.freeze({
    manifestKey: manifest.manifestKey,
    envelopeKey: manifest.envelopeKey,
    packageKey: manifest.packageKey,
    gateKey: manifest.gateKey,
    decisionKey: manifest.decisionKey,
    readinessKey: manifest.readinessKey,
    ownerKey: manifest.ownerKey,
    exportKey: manifest.exportKey,
    registryKey: manifest.registryKey,
    contractId: manifest.contractId,
    manifestStatus: manifest.manifestStatus,
    deliveryReady: manifest.deliveryReady,
    manifestReasonCount: manifest.manifestReasons.length,
    signalCount: manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
