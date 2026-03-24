/**
 * Phase 138 — Governance Runtime Registry Export Selector
 *
 * Read-only deterministic registry-facing selection surface.
 */

import type { GovernanceRuntimeRegistryExport } from "./governance_runtime_registry_export";

export interface GovernanceRuntimeRegistryExportSelection {
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

export function selectGovernanceRuntimeRegistryExport(
  registryExport: GovernanceRuntimeRegistryExport
): GovernanceRuntimeRegistryExportSelection {
  return Object.freeze({
    exportKey: registryExport.exportKey,
    registryKey: registryExport.registryKey,
    contractId: registryExport.contractId,
    channel: registryExport.channel,
    surface: registryExport.surface,
    mode: registryExport.mode,
    signalCount: registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
