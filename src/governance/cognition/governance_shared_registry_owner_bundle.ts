/**
 * Phase 139 — Governance Shared Registry Owner Bundle
 *
 * Deterministic shared-registry-owner-facing governance export bundle.
 *
 * No DOM mutation.
 * No UI rendering.
 * No execution coupling.
 * No async behavior.
 * No live runtime registry owner mutation.
 */

import type { GovernanceRuntimeRegistryExport } from "./governance_runtime_registry_export";

export interface GovernanceSharedRegistryOwnerBundle {
  readonly kind: "governance-shared-registry-owner-bundle";
  readonly version: 1;

  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";

  readonly channel: "dashboard";
  readonly surface: "governance";
  readonly mode: "read-only";

  readonly ts: number;

  readonly registryExport: GovernanceRuntimeRegistryExport;

  readonly operatorSafe: true;
  readonly dashboardSafe: true;
  readonly readOnly: true;
  readonly deterministic: true;
}
