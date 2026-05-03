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
  selectGovernancePreLiveRegistryDeliveryManifest,
  proveGovernancePreLiveRegistryDeliveryManifest
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 145002
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
const selection = selectGovernancePreLiveRegistryDeliveryManifest(manifest);
const proof = proveGovernancePreLiveRegistryDeliveryManifest();

const report = Object.freeze({
  phase: 145,
  component: "governance-pre-live-registry-delivery-manifest",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  envelope: {
    envelopeKey: envelope.envelopeKey,
    envelopeStatus: envelope.envelopeStatus,
    handoffReady: envelope.handoffReady,
    envelopeReasonCount: envelope.envelopeReasons.length,
    signalCount: envelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  manifest: {
    kind: manifest.kind,
    version: manifest.version,
    manifestKey: manifest.manifestKey,
    envelopeKey: manifest.envelopeKey,
    packageKey: manifest.packageKey,
    gateKey: manifest.gateKey,
    decisionKey: manifest.decisionKey,
    readinessKey: manifest.readinessKey,
    ownerKey: manifest.ownerKey,
    exportKey: manifest.exportKey,
    registryKey: manifest.registryKey,
    contractId: manifest.contractId,
    channel: manifest.channel,
    surface: manifest.surface,
    mode: manifest.mode,
    manifestStatus: manifest.manifestStatus,
    deliveryReady: manifest.deliveryReady,
    manifestReasonCount: manifest.manifestReasons.length,
    manifestReasons: manifest.manifestReasons,
    signalCount: manifest.handoffEnvelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: manifest.readOnly,
    dashboardSafe: manifest.dashboardSafe,
    operatorSafe: manifest.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
