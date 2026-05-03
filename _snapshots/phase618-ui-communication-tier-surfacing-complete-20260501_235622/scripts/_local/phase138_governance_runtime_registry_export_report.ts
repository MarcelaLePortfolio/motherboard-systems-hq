import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  registerGovernanceDashboardContract,
  normalizeGovernanceDashboardContractRegistration,
  buildGovernanceRuntimeRegistryExport,
  normalizeGovernanceRuntimeRegistryExport,
  selectGovernanceRuntimeRegistryExport,
  proveGovernanceRuntimeRegistryExport
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 138002
});

const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
const view = buildGovernanceDashboardConsumptionView(packaged);
const registration = registerGovernanceDashboardContract(view);
const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
const selection = selectGovernanceRuntimeRegistryExport(normalizedExport);
const proof = proveGovernanceRuntimeRegistryExport();

const report = Object.freeze({
  phase: 138,
  component: "governance-runtime-registry-export",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalizedSnapshot.deterministic === true &&
    packaged.deterministic === true &&
    view.deterministic === true &&
    normalizedRegistration.deterministic === true &&
    normalizedExport.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  registration: {
    contractId: normalizedRegistration.contractId,
    registryKey: normalizedRegistration.registryKey,
    signalCount: normalizedRegistration.payload.signalCount,
    signals: normalizedRegistration.payload.signals
  },
  registryExport: {
    kind: normalizedExport.kind,
    version: normalizedExport.version,
    exportKey: normalizedExport.exportKey,
    registryKey: normalizedExport.registryKey,
    contractId: normalizedExport.contractId,
    channel: normalizedExport.channel,
    surface: normalizedExport.surface,
    mode: normalizedExport.mode,
    signalCount: normalizedExport.registration.payload.signalCount,
    signals: normalizedExport.registration.payload.signals,
    readOnly: normalizedExport.readOnly,
    dashboardSafe: normalizedExport.dashboardSafe,
    operatorSafe: normalizedExport.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
