/**
 * Phase 141 — Governance Explicit Live Wiring Decision Proof
 *
 * Deterministic proof surface for final pre-authorization decisioning.
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
import { selectGovernanceLiveWiringDecision } from "./select_governance_live_wiring_decision";

export interface GovernanceLiveWiringDecisionProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly decisionStatus: "eligible" | "ineligible";
  readonly eligibleForExplicitLiveWiring: boolean;
  readonly decisionReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceLiveWiringDecision(): GovernanceLiveWiringDecisionProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 141000
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
  const selected = selectGovernanceLiveWiringDecision(decision);

  assert(
    decision.kind === "governance-live-wiring-decision",
    "Decision kind must match."
  );
  assert(
    decision.decisionKey === "governance-live-wiring-decision",
    "Decision key must match."
  );
  assert(
    decision.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    decision.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    decision.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    decision.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    decision.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(decision.readOnly === true, "Decision must remain read-only.");
  assert(decision.decisionStatus === "eligible", "Decision status must evaluate to eligible.");
  assert(decision.eligibleForExplicitLiveWiring === true, "Decision eligibility must evaluate to true.");
  assert(selected.signalCount === 3, "Selected decision signal count must match normalized signal count.");
  assert(selected.decisionReasonCount >= 4, "Decision must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    decisionKey: selected.decisionKey,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    decisionStatus: selected.decisionStatus,
    eligibleForExplicitLiveWiring: selected.eligibleForExplicitLiveWiring,
    decisionReasonCount: selected.decisionReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
