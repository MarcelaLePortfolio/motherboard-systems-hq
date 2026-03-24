/**
 * Phase 147 — Governance Final Pre-Live Registry Archive Record Proof
 *
 * Deterministic proof surface for final archival preparation.
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
import { selectGovernanceFinalPreLiveRegistryArchiveRecord } from "./select_governance_final_pre_live_registry_archive_record";

export interface GovernanceFinalPreLiveRegistryArchiveRecordProof {
  readonly pass: true;
  readonly deterministic: true;
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
  readonly archiveStatus: "recorded";
  readonly archivalReady: boolean;
  readonly archiveReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceFinalPreLiveRegistryArchiveRecord(): GovernanceFinalPreLiveRegistryArchiveRecordProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 147000
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
  const selected = selectGovernanceFinalPreLiveRegistryArchiveRecord(archiveRecord);

  assert(archiveRecord.kind === "governance-final-pre-live-registry-archive-record", "Archive record kind must match.");
  assert(archiveRecord.archiveKey === "governance-final-pre-live-registry-archive-record", "Archive key must match.");
  assert(archiveRecord.receiptKey === "governance-final-delivery-receipt", "Receipt key must match.");
  assert(archiveRecord.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
  assert(archiveRecord.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
  assert(archiveRecord.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
  assert(archiveRecord.gateKey === "governance-authorization-gate", "Gate key must match.");
  assert(archiveRecord.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
  assert(archiveRecord.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
  assert(archiveRecord.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
  assert(archiveRecord.exportKey === "governance-runtime-registry-export", "Export key must match.");
  assert(archiveRecord.registryKey === "governance-dashboard-consumption", "Registry key must match.");
  assert(archiveRecord.contractId === "governance.dashboard.consumption", "Contract id must match.");
  assert(archiveRecord.readOnly === true, "Archive record must remain read-only.");
  assert(archiveRecord.archiveStatus === "recorded", "Archive status must evaluate to recorded.");
  assert(archiveRecord.archivalReady === true, "Archive readiness must evaluate to true.");
  assert(selected.signalCount === 3, "Selected archive signal count must match normalized signal count.");
  assert(selected.archiveReasonCount >= 4, "Archive record must expose deterministic reasons.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
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
    archiveStatus: selected.archiveStatus,
    archivalReady: selected.archivalReady,
    archiveReasonCount: selected.archiveReasonCount,
    signalCount: selected.signalCount,
    readOnly: true as const
  });
}
