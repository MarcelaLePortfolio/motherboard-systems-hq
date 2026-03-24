/**
 * Phase 139 — Governance Shared Registry Owner Bundle Builder
 *
 * Pure deterministic adapter from runtime-registry-facing export
 * to shared-registry-owner-facing bundle.
 */

import type { GovernanceRuntimeRegistryExport } from "./governance_runtime_registry_export";
import type { GovernanceSharedRegistryOwnerBundle } from "./governance_shared_registry_owner_bundle";

export function buildGovernanceSharedRegistryOwnerBundle(
  registryExport: GovernanceRuntimeRegistryExport
): GovernanceSharedRegistryOwnerBundle {
  return Object.freeze({
    kind: "governance-shared-registry-owner-bundle" as const,
    version: 1 as const,

    ownerKey: "shared-runtime-registry-owner" as const,
    exportKey: registryExport.exportKey,
    registryKey: registryExport.registryKey,
    contractId: registryExport.contractId,

    channel: registryExport.channel,
    surface: registryExport.surface,
    mode: registryExport.mode,

    ts: registryExport.ts,

    registryExport,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
