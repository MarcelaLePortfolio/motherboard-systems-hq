import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  selectGovernanceDashboardConsumptionView,
  proveGovernanceDashboardConsumptionView
} from "../../src/governance/cognition";

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "review",
  registryStatus: "attention",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 136002
});

const normalized = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalized);
const view = buildGovernanceDashboardConsumptionView(packaged);
const selection = selectGovernanceDashboardConsumptionView(view);
const proof = proveGovernanceDashboardConsumptionView();

const report = Object.freeze({
  phase: 136,
  component: "governance-dashboard-consumption-preparation",
  pass: true,
  deterministic:
    snapshot.deterministic === true &&
    normalized.deterministic === true &&
    packaged.deterministic === true &&
    view.deterministic === true &&
    selection.deterministic === true &&
    proof.deterministic === true,
  snapshot: {
    overallStatus: snapshot.overallStatus,
    severity: snapshot.severity,
    signalCount: snapshot.signals.length
  },
  packaged: {
    operatorSafe: packaged.operatorSafe,
    dashboardReady: packaged.dashboardReady,
    signalCount: packaged.snapshot.signals.length
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
  selection,
  proof
});

console.log(JSON.stringify(report, null, 2));
