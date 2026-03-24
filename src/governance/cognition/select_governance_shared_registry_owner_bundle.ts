/**
 * Phase 139 — Governance Shared Registry Owner Bundle Selector
 *
 * Read-only deterministic owner-facing selection surface.
 */

import type { GovernanceSharedRegistryOwnerBundle } from "./governance_shared_registry_owner_bundle";

export interface GovernanceSharedRegistryOwnerBundleSelection {
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceSharedRegistryOwnerBundle(
  ownerBundle: GovernanceSharedRegistryOwnerBundle
): GovernanceSharedRegistryOwnerBundleSelection {
  return Object.freeze({
    ownerKey: ownerBundle.ownerKey,
    exportKey: ownerBundle.exportKey,
    registryKey: ownerBundle.registryKey,
    contractId: ownerBundle.contractId,
    channel: ownerBundle.channel,
    surface: ownerBundle.surface,
    mode: ownerBundle.mode,
    signalCount: ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
