/**
 * Phase 148 — Governance Final Pre-Live Registry Summary Capsule Builder
 *
 * Pure deterministic adapter from final pre-live registry archive record
 * to final pre-live summary surface.
 */

import type { GovernanceFinalPreLiveRegistryArchiveRecord } from "./governance_final_pre_live_registry_archive_record";
import type { GovernanceFinalPreLiveRegistrySummaryCapsule } from "./governance_final_pre_live_registry_summary_capsule";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceFinalPreLiveRegistrySummaryCapsule(
  archiveRecord: GovernanceFinalPreLiveRegistryArchiveRecord
): GovernanceFinalPreLiveRegistrySummaryCapsule {
  const summaryReady = archiveRecord.archivalReady === true;

  const capsuleReasons = uniqueSorted([
    ...archiveRecord.archiveReasons,
    "summary-capsule-created",
    summaryReady ? "summary-ready" : "summary-not-ready"
  ]);

  return Object.freeze({
    kind: "governance-final-pre-live-registry-summary-capsule" as const,
    version: 1 as const,

    capsuleKey: "governance-final-pre-live-registry-summary-capsule" as const,
    archiveKey: archiveRecord.archiveKey,
    receiptKey: archiveRecord.receiptKey,
    manifestKey: archiveRecord.manifestKey,
    envelopeKey: archiveRecord.envelopeKey,
    packageKey: archiveRecord.packageKey,
    gateKey: archiveRecord.gateKey,
    decisionKey: archiveRecord.decisionKey,
    readinessKey: archiveRecord.readinessKey,
    ownerKey: archiveRecord.ownerKey,
    exportKey: archiveRecord.exportKey,
    registryKey: archiveRecord.registryKey,
    contractId: archiveRecord.contractId,

    channel: archiveRecord.channel,
    surface: archiveRecord.surface,
    mode: archiveRecord.mode,

    ts: archiveRecord.ts,

    capsuleStatus: "summarized" as const,
    summaryReady,
    capsuleReasons,

    archiveRecord,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
