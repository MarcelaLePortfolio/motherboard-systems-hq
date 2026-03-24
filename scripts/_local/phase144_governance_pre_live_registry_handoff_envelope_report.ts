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
  selectGovernancePreLiveRegistryHandoffEnvelope,
  proveGovernancePreLiveRegistryHandoffEnvelope
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 144002
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
const selection = selectGovernancePreLiveRegistryHandoffEnvelope(envelope);
const proof = proveGovernancePreLiveRegistryHandoffEnvelope();

const report = Object.freeze({
  phase: 144,
  component: "governance-pre-live-registry-handoff-envelope",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  contractPackage: {
    packageKey: contractPackage.packageKey,
    packageStatus: contractPackage.packageStatus,
    handoffEligible: contractPackage.handoffEligible,
    packageReasonCount: contractPackage.packageReasons.length,
    signalCount: contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  envelope: {
    kind: envelope.kind,
    version: envelope.version,
    envelopeKey: envelope.envelopeKey,
    packageKey: envelope.packageKey,
    gateKey: envelope.gateKey,
    decisionKey: envelope.decisionKey,
    readinessKey: envelope.readinessKey,
    ownerKey: envelope.ownerKey,
    exportKey: envelope.exportKey,
    registryKey: envelope.registryKey,
    contractId: envelope.contractId,
    channel: envelope.channel,
    surface: envelope.surface,
    mode: envelope.mode,
    envelopeStatus: envelope.envelopeStatus,
    handoffReady: envelope.handoffReady,
    envelopeReasonCount: envelope.envelopeReasons.length,
    envelopeReasons: envelope.envelopeReasons,
    signalCount: envelope.contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: envelope.readOnly,
    dashboardSafe: envelope.dashboardSafe,
    operatorSafe: envelope.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
