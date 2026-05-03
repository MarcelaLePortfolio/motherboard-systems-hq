/**
 * Phase 148 — Governance Final Pre-Live Registry Summary Capsule Selector
 *
 * Read-only deterministic summary selection surface.
 */

import type { GovernanceFinalPreLiveRegistrySummaryCapsule } from "./governance_final_pre_live_registry_summary_capsule";

export interface GovernanceFinalPreLiveRegistrySummaryCapsuleSelection {
  readonly capsuleKey: "governance-final-pre-live-registry-summary-capsule";
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
  readonly capsuleStatus: "summarized";
  readonly summaryReady: boolean;
  readonly capsuleReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceFinalPreLiveRegistrySummaryCapsule(
  capsule: GovernanceFinalPreLiveRegistrySummaryCapsule
): GovernanceFinalPreLiveRegistrySummaryCapsuleSelection {
  return Object.freeze({
    capsuleKey: capsule.capsuleKey,
    archiveKey: capsule.archiveKey,
    receiptKey: capsule.receiptKey,
    manifestKey: capsule.manifestKey,
    envelopeKey: capsule.envelopeKey,
    packageKey: capsule.packageKey,
    gateKey: capsule.gateKey,
    decisionKey: capsule.decisionKey,
    readinessKey: capsule.readinessKey,
    ownerKey: capsule.ownerKey,
    exportKey: capsule.exportKey,
    registryKey: capsule.registryKey,
    contractId: capsule.contractId,
    capsuleStatus: capsule.capsuleStatus,
    summaryReady: capsule.summaryReady,
    capsuleReasonCount: capsule.capsuleReasons.length,
    signalCount: capsule.archiveRecord.receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
