/**
 * Phase 146 — Governance Final Delivery Receipt Selector
 *
 * Read-only deterministic acknowledgement selection surface.
 */

import type { GovernanceFinalDeliveryReceipt } from "./governance_final_delivery_receipt";

export interface GovernanceFinalDeliveryReceiptSelection {
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
  readonly receiptStatus: "acknowledged";
  readonly acknowledgementReady: boolean;
  readonly receiptReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceFinalDeliveryReceipt(
  receipt: GovernanceFinalDeliveryReceipt
): GovernanceFinalDeliveryReceiptSelection {
  return Object.freeze({
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
    receiptStatus: receipt.receiptStatus,
    acknowledgementReady: receipt.acknowledgementReady,
    receiptReasonCount: receipt.receiptReasons.length,
    signalCount: receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
