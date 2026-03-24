/**
 * Phase 140 — Governance Live Registry Wiring Readiness
 *
 * Deterministic final readiness surface for evaluating governance shared
 * registry owner bundles before any explicitly authorized live runtime
 * registry owner wiring.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceSharedRegistryOwnerBundle } from "./governance_shared_registry_owner_bundle";

export interface GovernanceLiveRegistryWiringReadiness {
  readonly kind: "governance-live-registry-wiring-readiness";
  readonly version: 1;

  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly readyForLiveOwnerWiring: boolean;
  readonly readinessReasons: readonly string[];

  readonly ownerBundle: GovernanceSharedRegistryOwnerBundle;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
