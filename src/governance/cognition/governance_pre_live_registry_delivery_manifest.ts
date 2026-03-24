/**
 * Phase 145 — Governance Pre-Live Registry Delivery Manifest
 *
 * Deterministic delivery manifest referencing the pre-live registry handoff
 * envelope for future explicitly authorized live runtime registry owner work,
 * without performing that work.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernancePreLiveRegistryHandoffEnvelope } from "./governance_pre_live_registry_handoff_envelope";

export interface GovernancePreLiveRegistryDeliveryManifest {
  readonly kind: "governance-pre-live-registry-delivery-manifest";
  readonly version: 1;

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

  readonly manifestStatus: "prepared";
  readonly deliveryReady: boolean;
  readonly manifestReasons: readonly string[];

  readonly handoffEnvelope: GovernancePreLiveRegistryHandoffEnvelope;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
