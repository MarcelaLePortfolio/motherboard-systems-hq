/**
 * Phase 144 — Governance Pre-Live Registry Handoff Envelope Proof
 *
 * Deterministic proof surface for final pre-live handoff wrapper.
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
import { buildGovernancePreLiveRegistryHandoffEnvelope } from "./build_governance_pre_live_registry_handoff_envelope";
import { selectGovernancePreLiveRegistryHandoffEnvelope } from "./select_governance_pre_live_registry_handoff_envelope";

export interface GovernancePreLiveRegistryHandoffEnvelopeProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly envelopeKey: "governance-pre-live-registry-handoff-envelope";
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly envelopeStatus: "wrapped";
  readonly handoffReady: boolean;
  readonly envelopeReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernancePreLiveRegistryHandoffEnvelope(): GovernancePreLiveRegistryHandoffEnvelopeProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 144000
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
  const envelope = buildGovernancePreLiveRegistryHandoffEnvelope(contractPackage);
  const selected = selectGovernancePreLiveRegistryHandoffEnvelope(envelope);

  assert(
    envelope.kind === "governance-pre-live-registry-handoff-envelope",
    "Envelope kind must match."
  );
  assert(
    envelope.envelopeKey === "governance-pre-live-registry-handoff-envelope",
    "Envelope key must match."
  );
  assert(
    envelope.packageKey === "governance-final-pre-live-registry-contract-package",
    "Package key must match."
  );
  assert(
    envelope.gateKey === "governance-authorization-gate",
    "Gate key must match."
  );
  assert(
    envelope.decisionKey === "governance-live-wiring-decision",
    "Decision key must match."
  );
  assert(
    envelope.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    envelope.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    envelope.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    envelope.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    envelope.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(envelope.readOnly === true, "Envelope must remain read-only.");
  assert(envelope.envelopeStatus === "wrapped", "Envelope status must evaluate to wrapped.");
  assert(envelope.handoffReady === true, "Envelope handoff readiness must evaluate to true.");
  assert(selected.signalCount === 3, "Selected envelope signal count must match normalized signal count.");
  assert(selected.envelopeReasonCount >= 4, "Envelope must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    envelopeKey: selected.envelopeKey,
    packageKey: selected.packageKey,
    gateKey: selected.gateKey,
    decisionKey: selected.decisionKey,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    envelopeStatus: selected.envelopeStatus,
    handoffReady: selected.handoffReady,
    envelopeReasonCount: selected.envelopeReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
