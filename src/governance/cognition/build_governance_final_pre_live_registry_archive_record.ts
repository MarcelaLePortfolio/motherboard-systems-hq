/**
 * Phase 147 — Governance Final Pre-Live Registry Archive Record Builder
 *
 * Pure deterministic adapter from final delivery receipt
 * to final archival surface.
 */

import type { GovernanceFinalDeliveryReceipt } from "./governance_final_delivery_receipt";
import type { GovernanceFinalPreLiveRegistryArchiveRecord } from "./governance_final_pre_live_registry_archive_record";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceFinalPreLiveRegistryArchiveRecord(
  receipt: GovernanceFinalDeliveryReceipt
): GovernanceFinalPreLiveRegistryArchiveRecord {
  const archivalReady = receipt.acknowledgementReady === true;

  const archiveReasons = uniqueSorted([
    ...receipt.receiptReasons,
    "archive-record-created",
    archivalReady ? "archival-ready" : "archival-not-ready"
  ]);

  return Object.freeze({
    kind: "governance-final-pre-live-registry-archive-record" as const,
    version: 1 as const,

    archiveKey: "governance-final-pre-live-registry-archive-record" as const,
    receiptKey: receipt.receiptKey,
    manifestKey: receipt.manifestKey,
    envelopeKey: receipt.envelopeKey,
    packageKey: receipt.packageKey,
    gateKey: receipt.gateKey,
    decisionKey: receipt.decisionKey,
    readinessKey: receipt.readinessKey,
    ownerKey: receipt.ownerKey,
    exportKey: receipt.exportKey,
    registryKey: receipt.registryKey,
    contractId: receipt.contractId,

    channel: receipt.channel,
    surface: receipt.surface,
    mode: receipt.mode,

    ts: receipt.ts,

    archiveStatus: "recorded" as const,
    archivalReady,
    archiveReasons,

    receipt,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
