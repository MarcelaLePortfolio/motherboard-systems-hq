/**
 * Phase 139 — Governance Shared Registry Owner Bundle Normalization
 *
 * Defensive deterministic normalization for owner-facing export bundles.
 */

import type { GovernanceSharedRegistryOwnerBundle } from "./governance_shared_registry_owner_bundle";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function normalizeGovernanceSharedRegistryOwnerBundle(
  ownerBundle: GovernanceSharedRegistryOwnerBundle
): GovernanceSharedRegistryOwnerBundle {
  const normalizedSignals = uniqueSorted(
    ownerBundle.registryExport.registration.payload.signals
  );

  return Object.freeze({
    ...ownerBundle,
    registryExport: Object.freeze({
      ...ownerBundle.registryExport,
      registration: Object.freeze({
        ...ownerBundle.registryExport.registration,
        payload: Object.freeze({
          ...ownerBundle.registryExport.registration.payload,
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
    }),
    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
