/**
 * Phase 147 — Governance Final Pre-Live Registry Archive Record
 *
 * Deterministic archive record referencing the final delivery receipt for
 * future explicitly authorized live runtime registry owner work, without
 * performing that work.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceFinalDeliveryReceipt } from "./governance_final_delivery_receipt";

export interface GovernanceFinalPreLiveRegistryArchiveRecord {
  readonly kind: "governance-final-pre-live-registry-archive-record";
  readonly version: 1;

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

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly archiveStatus: "recorded";
  readonly archivalReady: boolean;
  readonly archiveReasons: readonly string[];

  readonly receipt: GovernanceFinalDeliveryReceipt;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
