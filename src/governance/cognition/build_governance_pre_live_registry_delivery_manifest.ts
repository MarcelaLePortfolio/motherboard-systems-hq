/**
 * Phase 145 — Governance Pre-Live Registry Delivery Manifest Builder
 *
 * Pure deterministic adapter from pre-live registry handoff envelope
 * to final pre-live delivery manifest surface.
 */

import type { GovernancePreLiveRegistryHandoffEnvelope } from "./governance_pre_live_registry_handoff_envelope";
import type { GovernancePreLiveRegistryDeliveryManifest } from "./governance_pre_live_registry_delivery_manifest";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernancePreLiveRegistryDeliveryManifest(
  handoffEnvelope: GovernancePreLiveRegistryHandoffEnvelope
): GovernancePreLiveRegistryDeliveryManifest {
  const deliveryReady = handoffEnvelope.handoffReady === true;

  const manifestReasons = uniqueSorted([
    ...handoffEnvelope.envelopeReasons,
    "delivery-manifest-prepared",
    deliveryReady ? "delivery-ready" : "delivery-not-ready"
  ]);

  return Object.freeze({
    kind: "governance-pre-live-registry-delivery-manifest" as const,
    version: 1 as const,

    manifestKey: "governance-pre-live-registry-delivery-manifest" as const,
    envelopeKey: handoffEnvelope.envelopeKey,
    packageKey: handoffEnvelope.packageKey,
    gateKey: handoffEnvelope.gateKey,
    decisionKey: handoffEnvelope.decisionKey,
    readinessKey: handoffEnvelope.readinessKey,
    ownerKey: handoffEnvelope.ownerKey,
    exportKey: handoffEnvelope.exportKey,
    registryKey: handoffEnvelope.registryKey,
    contractId: handoffEnvelope.contractId,

    channel: handoffEnvelope.channel,
    surface: handoffEnvelope.surface,
    mode: handoffEnvelope.mode,

    ts: handoffEnvelope.ts,

    manifestStatus: "prepared" as const,
    deliveryReady,
    manifestReasons,

    handoffEnvelope,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
