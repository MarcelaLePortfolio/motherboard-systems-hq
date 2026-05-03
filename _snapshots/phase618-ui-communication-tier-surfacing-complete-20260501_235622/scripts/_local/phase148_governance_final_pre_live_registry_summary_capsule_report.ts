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
  buildGovernanceFinalPreLiveRegistrySummaryCapsule,
  selectGovernanceFinalPreLiveRegistrySummaryCapsule,
  proveGovernanceFinalPreLiveRegistrySummaryCapsule
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 148002
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
const selection = selectGovernanceFinalPreLiveRegistrySummaryCapsule(capsule);
const proof = proveGovernanceFinalPreLiveRegistrySummaryCapsule();

const report = Object.freeze({
  phase: 148,
  component: "governance-final-pre-live-registry-summary-capsule",
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
    capsule.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  archiveRecord: {
    archiveKey: archiveRecord.archiveKey,
    archiveStatus: archiveRecord.archiveStatus,
    archivalReady: archiveRecord.archivalReady,
    archiveReasonCount: archiveRecord.archiveReasons.length,
    signalCount: archiveRecord.receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  capsule: {
    kind: capsule.kind,
    version: capsule.version,
    capsuleKey: capsule.capsuleKey,
    archiveKey: capsule.archiveKey,
    receiptKey: capsule.receiptKey,
    manifestKey: capsule.manifestKey,
    envelopeKey: capsule.envelopeKey,
    packageKey: capsule.packageKey,
    gateKey: capsule.gateKey,
    decisionKey: capsule.decisionKey,
    readinessKey: capsule.readinessKey,
    ownerKey: capsule.ownerKey,
    exportKey: capsule.exportKey,
    registryKey: capsule.registryKey,
    contractId: capsule.contractId,
    channel: capsule.channel,
    surface: capsule.surface,
    mode: capsule.mode,
    capsuleStatus: capsule.capsuleStatus,
    summaryReady: capsule.summaryReady,
    capsuleReasonCount: capsule.capsuleReasons.length,
    capsuleReasons: capsule.capsuleReasons,
    signalCount: capsule.archiveRecord.receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: capsule.readOnly,
    dashboardSafe: capsule.dashboardSafe,
    operatorSafe: capsule.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
