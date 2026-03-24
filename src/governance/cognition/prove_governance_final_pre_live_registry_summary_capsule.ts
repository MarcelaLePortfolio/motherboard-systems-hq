/**
 * Phase 148 — Governance Final Pre-Live Registry Summary Capsule Proof
 *
 * Deterministic proof surface for final pre-live summary preparation.
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
import { buildGovernanceFinalDeliveryReceipt } from "./build_governance_final_delivery_receipt";
import { buildGovernanceFinalPreLiveRegistryArchiveRecord } from "./build_governance_final_pre_live_registry_archive_record";
import { buildGovernanceFinalPreLiveRegistrySummaryCapsule } from "./build_governance_final_pre_live_registry_summary_capsule";
import { selectGovernanceFinalPreLiveRegistrySummaryCapsule } from "./select_governance_final_pre_live_registry_summary_capsule";

export interface GovernanceFinalPreLiveRegistrySummaryCapsuleProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly capsuleKey: "governance-final-pre-live-registry-summary-capsule";
  readonly archiveKey: "governance-final-pre-live-registry-archive-record";
  readonly receiptKey: "governance-final-delivery-receipt";
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
  readonly capsuleStatus: "summarized";
  readonly summaryReady: boolean;
  readonly capsuleReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceFinalPreLiveRegistrySummaryCapsule(): GovernanceFinalPreLiveRegistrySummaryCapsuleProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 148000
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
  const receipt = buildGovernanceFinalDeliveryReceipt(manifest);
  const archiveRecord = buildGovernanceFinalPreLiveRegistryArchiveRecord(receipt);
  const capsule = buildGovernanceFinalPreLiveRegistrySummaryCapsule(archiveRecord);
  const selected = selectGovernanceFinalPreLiveRegistrySummaryCapsule(capsule);

  assert(capsule.kind === "governance-final-pre-live-registry-summary-capsule", "Capsule kind must match.");
  assert(capsule.capsuleKey === "governance-final-pre-live-registry-summary-capsule", "Capsule key must match.");
  assert(capsule.archiveKey === "governance-final-pre-live-registry-archive-record", "Archive key must match.");
  assert(capsule.receiptKey === "governance-final-delivery-receipt", "Receipt key must match.");
  assert(capsule.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
  assert(capsule.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
  assert(capsule.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
  assert(capsule.gateKey === "governance-authorization-gate", "Gate key must match.");
  assert(capsule.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
  assert(capsule.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
  assert(capsule.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
  assert(capsule.exportKey === "governance-runtime-registry-export", "Export key must match.");
  assert(capsule.registryKey === "governance-dashboard-consumption", "Registry key must match.");
  assert(capsule.contractId === "governance.dashboard.consumption", "Contract id must match.");
  assert(capsule.readOnly === true, "Capsule must remain read-only.");
  assert(capsule.capsuleStatus === "summarized", "Capsule status must evaluate to summarized.");
  assert(capsule.summaryReady === true, "Capsule summary readiness must evaluate to true.");
  assert(selected.signalCount === 3, "Selected capsule signal count must match normalized signal count.");
  assert(selected.capsuleReasonCount >= 4, "Capsule must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    capsuleKey: selected.capsuleKey,
    archiveKey: selected.archiveKey,
    receiptKey: selected.receiptKey,
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
    capsuleStatus: selected.capsuleStatus,
    summaryReady: selected.summaryReady,
    capsuleReasonCount: selected.capsuleReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
