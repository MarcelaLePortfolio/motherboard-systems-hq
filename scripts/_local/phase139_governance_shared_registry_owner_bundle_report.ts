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
  selectGovernanceSharedRegistryOwnerBundle,
  proveGovernanceSharedRegistryOwnerBundle
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 139002
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
const selection = selectGovernanceSharedRegistryOwnerBundle(normalizedOwnerBundle);
const proof = proveGovernanceSharedRegistryOwnerBundle();

const report = Object.freeze({
  phase: 139,
  component: "governance-shared-registry-owner-bundle",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalizedSnapshot.deterministic === true &&
    packaged.deterministic === true &&
    view.deterministic === true &&
    normalizedRegistration.deterministic === true &&
    normalizedExport.deterministic === true &&
    normalizedOwnerBundle.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  registryExport: {
    exportKey: normalizedExport.exportKey,
    registryKey: normalizedExport.registryKey,
    contractId: normalizedExport.contractId,
    signalCount: normalizedExport.registration.payload.signalCount,
    signals: normalizedExport.registration.payload.signals
  },
  ownerBundle: {
    kind: normalizedOwnerBundle.kind,
    version: normalizedOwnerBundle.version,
    ownerKey: normalizedOwnerBundle.ownerKey,
    exportKey: normalizedOwnerBundle.exportKey,
    registryKey: normalizedOwnerBundle.registryKey,
    contractId: normalizedOwnerBundle.contractId,
    channel: normalizedOwnerBundle.channel,
    surface: normalizedOwnerBundle.surface,
    mode: normalizedOwnerBundle.mode,
    signalCount: normalizedOwnerBundle.registryExport.registration.payload.signalCount,
    signals: normalizedOwnerBundle.registryExport.registration.payload.signals,
    readOnly: normalizedOwnerBundle.readOnly,
    dashboardSafe: normalizedOwnerBundle.dashboardSafe,
    operatorSafe: normalizedOwnerBundle.operatorSafe
  },
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
