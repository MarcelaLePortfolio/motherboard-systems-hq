/**
 * Phase 140 — Governance Live Registry Wiring Readiness Proof
 *
 * Deterministic proof surface for final pre-live registry readiness.
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
import { buildGovernanceLiveRegistryWiringReadiness } from "./build_governance_live_registry_wiring_readiness";
import { selectGovernanceLiveRegistryWiringReadiness } from "./select_governance_live_registry_wiring_readiness";

export interface GovernanceLiveRegistryWiringReadinessProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly readyForLiveOwnerWiring: boolean;
  readonly readinessReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceLiveRegistryWiringReadiness(): GovernanceLiveRegistryWiringReadinessProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 140000
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
  const readiness = buildGovernanceLiveRegistryWiringReadiness(normalizedOwnerBundle);
  const selected = selectGovernanceLiveRegistryWiringReadiness(readiness);

  assert(
    readiness.kind === "governance-live-registry-wiring-readiness",
    "Readiness kind must match."
  );
  assert(
    readiness.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    readiness.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    readiness.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    readiness.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    readiness.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(readiness.readOnly === true, "Readiness must remain read-only.");
  assert(readiness.readyForLiveOwnerWiring === true, "Readiness must evaluate to true.");
  assert(selected.signalCount === 3, "Selected readiness signal count must match normalized signal count.");
  assert(selected.readinessReasonCount >= 4, "Readiness must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    readyForLiveOwnerWiring: selected.readyForLiveOwnerWiring,
    readinessReasonCount: selected.readinessReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
