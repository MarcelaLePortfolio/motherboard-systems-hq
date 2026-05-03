/**
 * Phase 138 — Governance Runtime Registry Export Builder
 *
 * Pure deterministic adapter from governance dashboard contract registration
 * to runtime-registry-facing export surface.
 */

import type { GovernanceDashboardContractRegistration } from "./governance_dashboard_contract_registration";
import type { GovernanceRuntimeRegistryExport } from "./governance_runtime_registry_export";

export function buildGovernanceRuntimeRegistryExport(
  registration: GovernanceDashboardContractRegistration
): GovernanceRuntimeRegistryExport {
  return Object.freeze({
    kind: "governance-runtime-registry-export" as const,
    version: 1 as const,

    exportKey: "governance-runtime-registry-export" as const,
    registryKey: registration.registryKey,
    contractId: registration.contractId,

    channel: registration.channel,
    surface: registration.surface,
    mode: registration.mode,

    ts: registration.ts,

    registration,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
