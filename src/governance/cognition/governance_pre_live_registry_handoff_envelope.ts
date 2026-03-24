/**
 * Phase 144 — Governance Pre-Live Registry Handoff Envelope
 *
 * Deterministic handoff envelope wrapping the final pre-live registry
 * contract package for future explicitly authorized live runtime registry
 * owner work, without performing that work.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceFinalPreLiveRegistryContractPackage } from "./governance_final_pre_live_registry_contract_package";

export interface GovernancePreLiveRegistryHandoffEnvelope {
  readonly kind: "governance-pre-live-registry-handoff-envelope";
  readonly version: 1;

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

  readonly envelopeStatus: "wrapped";
  readonly handoffReady: boolean;
  readonly envelopeReasons: readonly string[];

  readonly contractPackage: GovernanceFinalPreLiveRegistryContractPackage;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
