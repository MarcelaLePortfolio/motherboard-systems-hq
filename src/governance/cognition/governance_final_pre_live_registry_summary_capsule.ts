/**
 * Phase 148 — Governance Final Pre-Live Registry Summary Capsule
 *
 * Deterministic summary capsule referencing the final pre-live registry
 * archive record for future explicitly authorized live runtime registry
 * owner work, without performing that work.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceFinalPreLiveRegistryArchiveRecord } from "./governance_final_pre_live_registry_archive_record";

export interface GovernanceFinalPreLiveRegistrySummaryCapsule {
  readonly kind: "governance-final-pre-live-registry-summary-capsule";
  readonly version: 1;

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

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly capsuleStatus: "summarized";
  readonly summaryReady: boolean;
  readonly capsuleReasons: readonly string[];

  readonly archiveRecord: GovernanceFinalPreLiveRegistryArchiveRecord;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
