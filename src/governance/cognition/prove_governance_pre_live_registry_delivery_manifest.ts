/**
 * Phase 145 — Governance Pre-Live Registry Delivery Manifest Proof
 *
 * Deterministic proof surface for final pre-live delivery manifest.
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
import { buildGovernancePreLiveRegistryDeliveryManifest } from "./build_governance_pre_live_registry_delivery_manifest";
import { selectGovernancePreLiveRegistryDeliveryManifest } from "./select_governance_pre_live_registry_delivery_manifest";

export interface GovernancePreLiveRegistryDeliveryManifestProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly manifestKey: "governance-pre-live-registry-delivery-manifest";
  readonly envelopeKey: "governance-pre-live-registry-handoff-envelope";
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly manifestStatus: "prepared";
  readonly deliveryReady: boolean;
  readonly manifestReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernancePreLiveRegistryDeliveryManifest(): GovernancePreLiveRegistryDeliveryManifestProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 145000
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
  const manifest = buildGovernancePreLiveRegistryDeliveryManifest(envelope);
  const selected = selectGovernancePreLiveRegistryDeliveryManifest(manifest);

  assert(
    manifest.kind === "governance-pre-live-registry-delivery-manifest",
    "Manifest kind must match."
  );
  assert(
    manifest.manifestKey === "governance-pre-live-registry-delivery-manifest",
    "Manifest key must match."
  );
  assert(
    manifest.envelopeKey === "governance-pre-live-registry-handoff-envelope",
    "Envelope key must match."
  );
  assert(
    manifest.packageKey === "governance-final-pre-live-registry-contract-package",
    "Package key must match."
  );
  assert(
    manifest.gateKey === "governance-authorization-gate",
    "Gate key must match."
  );
  assert(
    manifest.decisionKey === "governance-live-wiring-decision",
    "Decision key must match."
  );
  assert(
    manifest.readinessKey === "governance-live-registry-wiring-readiness",
    "Readiness key must match."
  );
  assert(
    manifest.ownerKey === "shared-runtime-registry-owner",
    "Owner key must match."
  );
  assert(
    manifest.exportKey === "governance-runtime-registry-export",
    "Export key must match."
  );
  assert(
    manifest.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(
    manifest.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(manifest.readOnly === true, "Manifest must remain read-only.");
  assert(manifest.manifestStatus === "prepared", "Manifest status must evaluate to prepared.");
  assert(manifest.deliveryReady === true, "Manifest delivery readiness must evaluate to true.");
  assert(selected.signalCount === 3, "Selected manifest signal count must match normalized signal count.");
  assert(selected.manifestReasonCount >= 4, "Manifest must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    manifestKey: selected.manifestKey,
    envelopeKey: selected.envelopeKey,
    packageKey: selected.packageKey,
    gateKey: selected.gateKey,
    decisionKey: selected.decisionKey,
    readinessKey: selected.readinessKey,
    ownerKey: selected.ownerKey,
    exportKey: selected.exportKey,
    registryKey: selected.registryKey,
    contractId: selected.contractId,
    manifestStatus: selected.manifestStatus,
    deliveryReady: selected.deliveryReady,
    manifestReasonCount: selected.manifestReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
