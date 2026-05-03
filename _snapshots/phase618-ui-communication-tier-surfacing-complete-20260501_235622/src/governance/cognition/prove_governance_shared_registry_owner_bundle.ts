/**
 * Phase 139 — Governance Shared Registry Owner Bundle Proof
 *
 * Deterministic proof surface for shared-registry-owner-facing bundle preparation.
 */

import { buildGovernanceCognitionSnapshot } from "./build_governance_cognition_snapshot";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";
import { packageGovernanceCognitionSnapshot } from "./package_governance_cognition_snapshot";
import { buildGovernanceDashboardConsumptionView } from "./build_governance_dashboard_consumption_view";
import { registerGovernanceDashboardContract } from "./register_governance_dashboard_contract";
import { normalizeGovernanceDashboardContractRegistration } from "./normalize_governance_dashboard_contract_registration";
import { buildGovernanceRuntimeRegistryExport } from "./build_governance_runtime_registry_export";
import { normalizeGovernanceRuntimeRegistryExport } from "./normalize_governance_runtime_registry_export";
import { buildGovernanceSharedRegistryOwnerBundle } from "./build_governance_shared_registry_owner_bundle";
import { normalizeGovernanceSharedRegistryOwnerBundle } from "./normalize_governance_shared_registry_owner_bundle";
import { selectGovernanceSharedRegistryOwnerBundle } from "./select_governance_shared_registry_owner_bundle";

export interface GovernanceSharedRegistryOwnerBundleProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly signalCount: number;
  readonly signals: readonly string[];
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceSharedRegistryOwnerBundle(): GovernanceSharedRegistryOwnerBundleProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 139000
  });

  const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
  const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
  const view = buildGovernanceDashboardConsumptionView(packaged);
  const registration = registerGovernanceDashboardContract(view);
  const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
  const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
  const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
  const ownerBundle = buildGovernanceSharedRegistryOwnerBundle(normalizedExport);
  const normalizedOwnerBundle = normalizeGovernanceSharedRegistryOwnerBundle(ownerBundle);
  const selected = selectGovernanceSharedRegistryOwnerBundle(normalizedOwnerBundle);

  assert(
    normalizedOwnerBundle.kind === "governance-shared-registry-owner-bundle",
    "Shared registry owner bundle kind must match."
  );
  assert(
    normalizedOwnerBundle.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    normalizedOwnerBundle.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    normalizedOwnerBundle.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    normalizedOwnerBundle.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(normalizedOwnerBundle.readOnly === true, "Owner bundle must remain read-only.");
  assert(
    normalizedOwnerBundle.registryExport.registration.payload.signals.join("|") === "authority|registry|routing",
    "Owner bundle signals must be deduplicated and sorted."
  );
  assert(
    normalizedOwnerBundle.registryExport.registration.payload.signalCount === 3,
    "Owner bundle signal count must reflect normalized unique signals."
  );
  assert(selected.signalCount === 3, "Selected owner bundle signal count must match normalized signal count.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    signalCount: selected.signalCount,
    signals: normalizedOwnerBundle.registryExport.registration.payload.signals,
    readOnly: true as const
  });
}
