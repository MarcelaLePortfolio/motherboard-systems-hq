/**
 * Phase 138 — Governance Runtime Registry Export Normalization
 *
 * Defensive deterministic normalization for registry-facing export surfaces.
 */

import type { GovernanceRuntimeRegistryExport } from "./governance_runtime_registry_export";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function normalizeGovernanceRuntimeRegistryExport(
  registryExport: GovernanceRuntimeRegistryExport
): GovernanceRuntimeRegistryExport {
  const normalizedSignals = uniqueSorted(registryExport.registration.payload.signals);

  return Object.freeze({
    ...registryExport,
    registration: Object.freeze({
      ...registryExport.registration,
      payload: Object.freeze({
        ...registryExport.registration.payload,
        signals: normalizedSignals,
        signalCount: normalizedSignals.length,
        operatorSafe: true as const,
        dashboardSafe: true as const,
        readOnly: true as const,
        deterministic: true as const
      }),
      operatorSafe: true as const,
      dashboardSafe: true as const,
      readOnly: true as const,
      deterministic: true as const
    }),
    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
