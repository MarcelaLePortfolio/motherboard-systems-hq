/**
 * Phase 146 — Governance Final Delivery Receipt Builder
 *
 * Pure deterministic adapter from pre-live registry delivery manifest
 * to final acknowledgement surface.
 */

import type { GovernancePreLiveRegistryDeliveryManifest } from "./governance_pre_live_registry_delivery_manifest";
import type { GovernanceFinalDeliveryReceipt } from "./governance_final_delivery_receipt";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceFinalDeliveryReceipt(
  manifest: GovernancePreLiveRegistryDeliveryManifest
): GovernanceFinalDeliveryReceipt {
  const acknowledgementReady = manifest.deliveryReady === true;

  const receiptReasons = uniqueSorted([
    ...manifest.manifestReasons,
    "delivery-receipt-issued",
    acknowledgementReady ? "acknowledgement-ready" : "acknowledgement-not-ready"
  ]);

  return Object.freeze({
    kind: "governance-final-delivery-receipt" as const,
    version: 1 as const,

    receiptKey: "governance-final-delivery-receipt" as const,
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

    channel: manifest.channel,
    surface: manifest.surface,
    mode: manifest.mode,

    ts: manifest.ts,

    receiptStatus: "acknowledged" as const,
    acknowledgementReady,
    receiptReasons,

    manifest,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
