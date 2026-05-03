import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  registerGovernanceDashboardContract,
  normalizeGovernanceDashboardContractRegistration,
  buildGovernanceRuntimeRegistryExport,
  normalizeGovernanceRuntimeRegistryExport,
  buildGovernanceSharedRegistryOwnerBundle,
  normalizeGovernanceSharedRegistryOwnerBundle,
  buildGovernanceLiveRegistryWiringReadiness,
  buildGovernanceLiveWiringDecision,
  buildGovernanceAuthorizationGate,
  buildGovernanceFinalPreLiveRegistryContractPackage,
  buildGovernancePreLiveRegistryHandoffEnvelope,
  buildGovernancePreLiveRegistryDeliveryManifest,
  buildGovernanceFinalDeliveryReceipt,
  buildGovernanceFinalPreLiveRegistryArchiveRecord,
  selectGovernanceFinalPreLiveRegistryArchiveRecord,
  proveGovernanceFinalPreLiveRegistryArchiveRecord
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 147002
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
const selection = selectGovernanceFinalPreLiveRegistryArchiveRecord(archiveRecord);
const proof = proveGovernanceFinalPreLiveRegistryArchiveRecord();

const report = Object.freeze({
  phase: 147,
  component: "governance-final-pre-live-registry-archive-record",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalizedSnapshot.deterministic === true &&
    packagedSnapshot.deterministic === true &&
    view.deterministic === true &&
    normalizedRegistration.deterministic === true &&
    normalizedExport.deterministic === true &&
    normalizedOwnerBundle.deterministic === true &&
    readiness.deterministic === true &&
    decision.deterministic === true &&
    gate.deterministic === true &&
    contractPackage.deterministic === true &&
    envelope.deterministic === true &&
    manifest.deterministic === true &&
    receipt.deterministic === true &&
    archiveRecord.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  receipt: {
    receiptKey: receipt.receiptKey,
    receiptStatus: receipt.receiptStatus,
    acknowledgementReady: receipt.acknowledgementReady,
    receiptReasonCount: receipt.receiptReasons.length,
    signalCount: receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  archiveRecord: {
    kind: archiveRecord.kind,
    version: archiveRecord.version,
    archiveKey: archiveRecord.archiveKey,
    receiptKey: archiveRecord.receiptKey,
    manifestKey: archiveRecord.manifestKey,
    envelopeKey: archiveRecord.envelopeKey,
    packageKey: archiveRecord.packageKey,
    gateKey: archiveRecord.gateKey,
    decisionKey: archiveRecord.decisionKey,
    readinessKey: archiveRecord.readinessKey,
    ownerKey: archiveRecord.ownerKey,
    exportKey: archiveRecord.exportKey,
    registryKey: archiveRecord.registryKey,
    contractId: archiveRecord.contractId,
    channel: archiveRecord.channel,
    surface: archiveRecord.surface,
    mode: archiveRecord.mode,
    archiveStatus: archiveRecord.archiveStatus,
    archivalReady: archiveRecord.archivalReady,
    archiveReasonCount: archiveRecord.archiveReasons.length,
    archiveReasons: archiveRecord.archiveReasons,
    signalCount: archiveRecord.receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: archiveRecord.readOnly,
    dashboardSafe: archiveRecord.dashboardSafe,
    operatorSafe: archiveRecord.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
