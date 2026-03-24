import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  registerGovernanceDashboardContract,
  normalizeGovernanceDashboardContractRegistration,
  proveGovernanceDashboardContractRegistration
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 137002
});

const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
const view = buildGovernanceDashboardConsumptionView(packaged);
const registration = registerGovernanceDashboardContract(view);
const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
const proof = proveGovernanceDashboardContractRegistration();

const report = Object.freeze({
  phase: 137,
  component: "governance-dashboard-contract-registration",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalizedSnapshot.deterministic === true &&
    packaged.deterministic === true &&
    view.deterministic === true &&
    normalizedRegistration.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  view: {
    kind: view.kind,
    version: view.version,
    overallStatus: view.overallStatus,
    severity: view.severity,
    signalCount: view.signalCount,
    signals: view.signals,
    readOnly: view.readOnly,
    dashboardSafe: view.dashboardSafe
  },
  registration: {
    kind: normalizedRegistration.kind,
    version: normalizedRegistration.version,
    contractId: normalizedRegistration.contractId,
    registryKey: normalizedRegistration.registryKey,
    channel: normalizedRegistration.channel,
    surface: normalizedRegistration.surface,
    mode: normalizedRegistration.mode,
    readOnly: normalizedRegistration.readOnly,
    dashboardSafe: normalizedRegistration.dashboardSafe,
    operatorSafe: normalizedRegistration.operatorSafe,
    signalCount: normalizedRegistration.payload.signalCount,
    signals: normalizedRegistration.payload.signals
  },
  proof
});

console.log(JSON.stringify(report, null, 2));
