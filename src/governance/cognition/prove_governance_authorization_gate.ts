/**
 * Phase 142 — Governance Authorization Gate Proof
 *
 * Deterministic proof surface for final pre-execution authorization gating.
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
import { selectGovernanceAuthorizationGate } from "./select_governance_authorization_gate";

export interface GovernanceAuthorizationGateProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly gateStatus: "open" | "closed";
  readonly authorizationEligible: boolean;
  readonly authorizationReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceAuthorizationGate(): GovernanceAuthorizationGateProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 142000
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
  const decision = buildGovernanceLiveWiringDecision(readiness);
  const gate = buildGovernanceAuthorizationGate(decision);
  const selected = selectGovernanceAuthorizationGate(gate);

  assert(
    gate.kind === "governance-authorization-gate",
    "Authorization gate kind must match."
  );
  assert(
    gate.gateKey === "governance-authorization-gate",
    "Gate key must match."
  );
  assert(
    gate.decisionKey === "governance-live-wiring-decision",
    "Decision key must match."
  );
  assert(
    gate.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    gate.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    gate.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    gate.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    gate.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(gate.readOnly === true, "Authorization gate must remain read-only.");
  assert(gate.gateStatus === "open", "Authorization gate status must evaluate to open.");
  assert(gate.authorizationEligible === true, "Authorization gate eligibility must evaluate to true.");
  assert(selected.signalCount === 3, "Selected gate signal count must match normalized signal count.");
  assert(selected.authorizationReasonCount >= 4, "Authorization gate must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    gateKey: selected.gateKey,
    decisionKey: selected.decisionKey,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    gateStatus: selected.gateStatus,
    authorizationEligible: selected.authorizationEligible,
    authorizationReasonCount: selected.authorizationReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
