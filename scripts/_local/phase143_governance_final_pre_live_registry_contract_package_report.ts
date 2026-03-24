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
  selectGovernanceFinalPreLiveRegistryContractPackage,
  proveGovernanceFinalPreLiveRegistryContractPackage
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 143002
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
const selection = selectGovernanceFinalPreLiveRegistryContractPackage(contractPackage);
const proof = proveGovernanceFinalPreLiveRegistryContractPackage();

const report = Object.freeze({
  phase: 143,
  component: "governance-final-pre-live-registry-contract-package",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  gate: {
    gateKey: gate.gateKey,
    gateStatus: gate.gateStatus,
    authorizationEligible: gate.authorizationEligible,
    authorizationReasonCount: gate.authorizationReasons.length,
    signalCount: gate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  contractPackage: {
    kind: contractPackage.kind,
    version: contractPackage.version,
    packageKey: contractPackage.packageKey,
    gateKey: contractPackage.gateKey,
    decisionKey: contractPackage.decisionKey,
    readinessKey: contractPackage.readinessKey,
    ownerKey: contractPackage.ownerKey,
    exportKey: contractPackage.exportKey,
    registryKey: contractPackage.registryKey,
    contractId: contractPackage.contractId,
    channel: contractPackage.channel,
    surface: contractPackage.surface,
    mode: contractPackage.mode,
    packageStatus: contractPackage.packageStatus,
    handoffEligible: contractPackage.handoffEligible,
    packageReasonCount: contractPackage.packageReasons.length,
    packageReasons: contractPackage.packageReasons,
    signalCount: contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: contractPackage.readOnly,
    dashboardSafe: contractPackage.dashboardSafe,
    operatorSafe: contractPackage.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
