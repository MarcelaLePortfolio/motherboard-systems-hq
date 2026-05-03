/**
 * Phase 138 — Governance Runtime Registry Export Proof
 *
 * Deterministic proof surface for runtime-registry-facing export preparation.
 */

import { buildGovernanceCognitionSnapshot } from "./build_governance_cognition_snapshot";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";
import { packageGovernanceCognitionSnapshot } from "./package_governance_cognition_snapshot";
import { buildGovernanceDashboardConsumptionView } from "./build_governance_dashboard_consumption_view";
import { registerGovernanceDashboardContract } from "./register_governance_dashboard_contract";
import { normalizeGovernanceDashboardContractRegistration } from "./normalize_governance_dashboard_contract_registration";
import { buildGovernanceRuntimeRegistryExport } from "./build_governance_runtime_registry_export";
import { selectGovernanceRuntimeRegistryExport } from "./select_governance_runtime_registry_export";
import { normalizeGovernanceRuntimeRegistryExport } from "./normalize_governance_runtime_registry_export";

export interface GovernanceRuntimeRegistryExportProof {
  readonly pass: true;
  readonly deterministic: true;
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

export function proveGovernanceRuntimeRegistryExport(): GovernanceRuntimeRegistryExportProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 138000
  });

  const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
  const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
  const view = buildGovernanceDashboardConsumptionView(packaged);
  const registration = registerGovernanceDashboardContract(view);
  const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
  const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
  const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
  const selected = selectGovernanceRuntimeRegistryExport(normalizedExport);

  assert(
    normalizedExport.kind === "governance-runtime-registry-export",
    "Runtime registry export kind must match."
  );
  assert(
    normalizedExport.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    normalizedExport.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    normalizedExport.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(normalizedExport.readOnly === true, "Runtime registry export must remain read-only.");
  assert(
    normalizedExport.registration.payload.signals.join("|") === "authority|registry|routing",
    "Runtime registry export signals must be deduplicated and sorted."
  );
  assert(
    normalizedExport.registration.payload.signalCount === 3,
    "Runtime registry export signal count must reflect normalized unique signals."
  );
  assert(selected.signalCount === 3, "Selected export signal count must match normalized signal count.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    signalCount: selected.signalCount,
    signals: normalizedExport.registration.payload.signals,
    readOnly: true as const
  });
}
