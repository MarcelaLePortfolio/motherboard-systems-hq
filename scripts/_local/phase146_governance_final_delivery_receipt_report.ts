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
  selectGovernanceFinalDeliveryReceipt,
  proveGovernanceFinalDeliveryReceipt
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 146002
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
const selection = selectGovernanceFinalDeliveryReceipt(receipt);
const proof = proveGovernanceFinalDeliveryReceipt();

const report = Object.freeze({
  phase: 146,
  component: "governance-final-delivery-receipt",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  manifest: {
    manifestKey: manifest.manifestKey,
    manifestStatus: manifest.manifestStatus,
    deliveryReady: manifest.deliveryReady,
    manifestReasonCount: manifest.manifestReasons.length,
    signalCount: manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  receipt: {
    kind: receipt.kind,
    version: receipt.version,
    receiptKey: receipt.receiptKey,
    manifestKey: receipt.manifestKey,
    envelopeKey: receipt.envelopeKey,
    packageKey: receipt.packageKey,
    gateKey: receipt.gateKey,
    decisionKey: receipt.decisionKey,
    readinessKey: receipt.readinessKey,
    ownerKey: receipt.ownerKey,
    exportKey: receipt.exportKey,
    registryKey: receipt.registryKey,
    contractId: receipt.contractId,
    channel: receipt.channel,
    surface: receipt.surface,
    mode: receipt.mode,
    receiptStatus: receipt.receiptStatus,
    acknowledgementReady: receipt.acknowledgementReady,
    receiptReasonCount: receipt.receiptReasons.length,
    receiptReasons: receipt.receiptReasons,
    signalCount: receipt.manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: receipt.readOnly,
    dashboardSafe: receipt.dashboardSafe,
    operatorSafe: receipt.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
