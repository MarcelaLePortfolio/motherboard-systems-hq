/**
 * Phase 143 — Governance Final Pre-Live Registry Contract Package Proof
 *
 * Deterministic proof surface for final bundled pre-live registry package.
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
import { buildGovernanceLiveWiringDecision } from "./build_governance_live_wiring_decision";
import { buildGovernanceAuthorizationGate } from "./build_governance_authorization_gate";
import { buildGovernanceFinalPreLiveRegistryContractPackage } from "./build_governance_final_pre_live_registry_contract_package";
import { selectGovernanceFinalPreLiveRegistryContractPackage } from "./select_governance_final_pre_live_registry_contract_package";

export interface GovernanceFinalPreLiveRegistryContractPackageProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly packageStatus: "prepared";
  readonly handoffEligible: boolean;
  readonly packageReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceFinalPreLiveRegistryContractPackage(): GovernanceFinalPreLiveRegistryContractPackageProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 143000
  });

  const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
  const packagedSnapshot = packageGovernanceCognitionSnapshot(normalizedSnapshot);
  const view = buildGovernanceDashboardConsumptionView(packagedSnapshot);
  const registration = registerGovernanceDashboardContract(view);
  const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
  const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
  const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
  const ownerBundle = buildGovernanceSharedRegistryOwnerBundle(normalizedExport);
  const normalizedOwnerBundle = normalizeGovernanceSharedRegistryOwnerBundle(ownerBundle);
  const readiness = buildGovernanceLiveRegistryWiringReadiness(normalizedOwnerBundle);
  const decision = buildGovernanceLiveWiringDecision(readiness);
  const gate = buildGovernanceAuthorizationGate(decision);
  const contractPackage = buildGovernanceFinalPreLiveRegistryContractPackage(gate);
  const selected = selectGovernanceFinalPreLiveRegistryContractPackage(contractPackage);

  assert(
    contractPackage.kind === "governance-final-pre-live-registry-contract-package",
    "Contract package kind must match."
  );
  assert(
    contractPackage.packageKey === "governance-final-pre-live-registry-contract-package",
    "Package key must match."
  );
  assert(
    contractPackage.gateKey === "governance-authorization-gate",
    "Gate key must match."
  );
  assert(
    contractPackage.decisionKey === "governance-live-wiring-decision",
    "Decision key must match."
  );
  assert(
    contractPackage.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    contractPackage.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    contractPackage.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    contractPackage.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    contractPackage.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(contractPackage.readOnly === true, "Contract package must remain read-only.");
  assert(contractPackage.packageStatus === "prepared", "Package status must evaluate to prepared.");
  assert(contractPackage.handoffEligible === true, "Contract package handoff eligibility must evaluate to true.");
  assert(selected.signalCount === 3, "Selected package signal count must match normalized signal count.");
  assert(selected.packageReasonCount >= 4, "Contract package must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    packageKey: selected.packageKey,
    gateKey: selected.gateKey,
    decisionKey: selected.decisionKey,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    packageStatus: selected.packageStatus,
    handoffEligible: selected.handoffEligible,
    packageReasonCount: selected.packageReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
