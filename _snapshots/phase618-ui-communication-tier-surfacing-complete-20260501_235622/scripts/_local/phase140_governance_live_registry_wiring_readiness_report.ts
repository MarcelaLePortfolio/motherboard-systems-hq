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
  selectGovernanceLiveRegistryWiringReadiness,
  proveGovernanceLiveRegistryWiringReadiness
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 140002
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
const selection = selectGovernanceLiveRegistryWiringReadiness(readiness);
const proof = proveGovernanceLiveRegistryWiringReadiness();

const report = Object.freeze({
  phase: 140,
  component: "governance-live-registry-wiring-readiness",
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
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  ownerBundle: {
    ownerKey: normalizedOwnerBundle.ownerKey,
    exportKey: normalizedOwnerBundle.exportKey,
    registryKey: normalizedOwnerBundle.registryKey,
    contractId: normalizedOwnerBundle.contractId,
    signalCount: normalizedOwnerBundle.registryExport.registration.payload.signalCount,
    signals: normalizedOwnerBundle.registryExport.registration.payload.signals
  },
  readiness: {
    kind: readiness.kind,
    version: readiness.version,
    readinessKey: readiness.readinessKey,
    ownerKey: readiness.ownerKey,
    exportKey: readiness.exportKey,
    registryKey: readiness.registryKey,
    contractId: readiness.contractId,
    channel: readiness.channel,
    surface: readiness.surface,
    mode: readiness.mode,
    readyForLiveOwnerWiring: readiness.readyForLiveOwnerWiring,
    readinessReasonCount: readiness.readinessReasons.length,
    readinessReasons: readiness.readinessReasons,
    signalCount: readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: readiness.readOnly,
    dashboardSafe: readiness.dashboardSafe,
    operatorSafe: readiness.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
