/**
 * Phase 140 — Governance Live Registry Wiring Readiness Selector
 *
 * Read-only deterministic readiness selection surface.
 */

import type { GovernanceLiveRegistryWiringReadiness } from "./governance_live_registry_wiring_readiness";

export interface GovernanceLiveRegistryWiringReadinessSelection {
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly readyForLiveOwnerWiring: boolean;
  readonly readinessReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceLiveRegistryWiringReadiness(
  readiness: GovernanceLiveRegistryWiringReadiness
): GovernanceLiveRegistryWiringReadinessSelection {
  return Object.freeze({
    readinessKey: readiness.readinessKey,
    ownerKey: readiness.ownerKey,
    exportKey: readiness.exportKey,
    registryKey: readiness.registryKey,
    contractId: readiness.contractId,
    readyForLiveOwnerWiring: readiness.readyForLiveOwnerWiring,
    readinessReasonCount: readiness.readinessReasons.length,
    signalCount: readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
