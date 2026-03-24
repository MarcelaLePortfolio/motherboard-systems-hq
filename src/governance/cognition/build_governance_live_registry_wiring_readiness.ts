/**
 * Phase 140 — Governance Live Registry Wiring Readiness Builder
 *
 * Pure deterministic adapter from shared-registry-owner-facing bundle
 * to final pre-live registry readiness surface.
 */

import type { GovernanceSharedRegistryOwnerBundle } from "./governance_shared_registry_owner_bundle";
import type { GovernanceLiveRegistryWiringReadiness } from "./governance_live_registry_wiring_readiness";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceLiveRegistryWiringReadiness(
  ownerBundle: GovernanceSharedRegistryOwnerBundle
): GovernanceLiveRegistryWiringReadiness {
  const reasons = uniqueSorted([
    "dashboard-safe",
    "deterministic",
    "operator-safe",
    "read-only",
    ownerBundle.ownerKey,
    ownerBundle.exportKey,
    ownerBundle.registryKey,
    ownerBundle.contractId
  ]);

  const readyForLiveOwnerWiring =
    ownerBundle.readOnly === true &&
    ownerBundle.dashboardSafe === true &&
    ownerBundle.operatorSafe === true &&
    ownerBundle.deterministic === true &&
    ownerBundle.registryExport.registration.payload.signalCount >= 0;

  return Object.freeze({
    kind: "governance-live-registry-wiring-readiness" as const,
    version: 1 as const,

    readinessKey: "governance-live-registry-wiring-readiness" as const,
    ownerKey: ownerBundle.ownerKey,
    exportKey: ownerBundle.exportKey,
    registryKey: ownerBundle.registryKey,
    contractId: ownerBundle.contractId,

    channel: ownerBundle.channel,
    surface: ownerBundle.surface,
    mode: ownerBundle.mode,

    ts: ownerBundle.ts,

    readyForLiveOwnerWiring,
    readinessReasons: reasons,

    ownerBundle,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
