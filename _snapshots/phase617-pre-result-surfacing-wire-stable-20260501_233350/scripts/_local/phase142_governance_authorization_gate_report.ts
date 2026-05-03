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
  selectGovernanceAuthorizationGate,
  proveGovernanceAuthorizationGate
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 142002
});

const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
const view = buildGovernanceDashboardConsumptionView(packaged);
const registration = registerGovernanceDashboardContract(view);
const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
const ownerBundle = buildGovernanceSharedRegistryOwnerBundle(normalizedExport);
const normalizedOwnerBundle = normalizeGovernanceSharedRegistryOwnerBundle(ownerBundle);
const readiness = buildGovernanceLiveRegistryWiringReadiness(normalizedOwnerBundle);
const decision = buildGovernanceLiveWiringDecision(readiness);
const gate = buildGovernanceAuthorizationGate(decision);
const selection = selectGovernanceAuthorizationGate(gate);
const proof = proveGovernanceAuthorizationGate();

const report = Object.freeze({
  phase: 142,
  component: "governance-authorization-gate",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalizedSnapshot.deterministic === true &&
    packaged.deterministic === true &&
    view.deterministic === true &&
    normalizedRegistration.deterministic === true &&
    normalizedExport.deterministic === true &&
    normalizedOwnerBundle.deterministic === true &&
    readiness.deterministic === true &&
    decision.deterministic === true &&
    gate.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  decision: {
    decisionKey: decision.decisionKey,
    decisionStatus: decision.decisionStatus,
    eligibleForExplicitLiveWiring: decision.eligibleForExplicitLiveWiring,
    decisionReasonCount: decision.decisionReasons.length,
    signalCount: decision.readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  gate: {
    kind: gate.kind,
    version: gate.version,
    gateKey: gate.gateKey,
    decisionKey: gate.decisionKey,
    readinessKey: gate.readinessKey,
    ownerKey: gate.ownerKey,
    exportKey: gate.exportKey,
    registryKey: gate.registryKey,
    contractId: gate.contractId,
    channel: gate.channel,
    surface: gate.surface,
    mode: gate.mode,
    gateStatus: gate.gateStatus,
    authorizationEligible: gate.authorizationEligible,
    authorizationReasonCount: gate.authorizationReasons.length,
    authorizationReasons: gate.authorizationReasons,
    signalCount: gate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: gate.readOnly,
    dashboardSafe: gate.dashboardSafe,
    operatorSafe: gate.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
