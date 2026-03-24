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
  selectGovernanceLiveWiringDecision,
  proveGovernanceLiveWiringDecision
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 141002
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
const selection = selectGovernanceLiveWiringDecision(decision);
const proof = proveGovernanceLiveWiringDecision();

const report = Object.freeze({
  phase: 141,
  component: "governance-live-wiring-decision",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  readiness: {
    readinessKey: readiness.readinessKey,
    ownerKey: readiness.ownerKey,
    exportKey: readiness.exportKey,
    registryKey: readiness.registryKey,
    contractId: readiness.contractId,
    readyForLiveOwnerWiring: readiness.readyForLiveOwnerWiring,
    readinessReasonCount: readiness.readinessReasons.length,
    signalCount: readiness.ownerBundle.registryExport.registration.payload.signalCount
  },
  decision: {
    kind: decision.kind,
    version: decision.version,
    decisionKey: decision.decisionKey,
    readinessKey: decision.readinessKey,
    ownerKey: decision.ownerKey,
    exportKey: decision.exportKey,
    registryKey: decision.registryKey,
    contractId: decision.contractId,
    channel: decision.channel,
    surface: decision.surface,
    mode: decision.mode,
    decisionStatus: decision.decisionStatus,
    eligibleForExplicitLiveWiring: decision.eligibleForExplicitLiveWiring,
    decisionReasonCount: decision.decisionReasons.length,
    decisionReasons: decision.decisionReasons,
    signalCount: decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: decision.readOnly,
    dashboardSafe: decision.dashboardSafe,
    operatorSafe: decision.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
