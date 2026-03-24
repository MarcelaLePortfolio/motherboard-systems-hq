/**
 * Phase 147 — Governance Final Pre-Live Registry Archive Record Selector
 *
 * Read-only deterministic archive selection surface.
 */

import type { GovernanceFinalPreLiveRegistryArchiveRecord } from "./governance_final_pre_live_registry_archive_record";

export interface GovernanceFinalPreLiveRegistryArchiveRecordSelection {
  readonly archiveKey: "governance-final-pre-live-registry-archive-record";
  readonly receiptKey: "governance-final-delivery-receipt";
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
  readonly archiveStatus: "recorded";
  readonly archivalReady: boolean;
  readonly archiveReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceFinalPreLiveRegistryArchiveRecord(
  archiveRecord: GovernanceFinalPreLiveRegistryArchiveRecord
): GovernanceFinalPreLiveRegistryArchiveRecordSelection {
  return Object.freeze({
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
    archiveStatus: archiveRecord.archiveStatus,
    archivalReady: archiveRecord.archivalReady,
    archiveReasonCount: archiveRecord.archiveReasons.length,
    signalCount: archiveRecord.receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
