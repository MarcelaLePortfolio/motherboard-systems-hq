import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  selectGovernanceDashboardConsumptionView,
  proveGovernanceDashboardConsumptionView
} from "../../src/governance/cognition";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

const snapshot = buildGovernanceCognitionSnapshot({
  routingStatus: "attention",
  authorityStatus: "stable",
  registryStatus: "stable",
  signals: ["routing", "authority", "routing"],
  ts: 136001
});

const normalized = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalized);
const view = buildGovernanceDashboardConsumptionView(packaged);
const selection = selectGovernanceDashboardConsumptionView(view);
const proof = proveGovernanceDashboardConsumptionView();

assert(view.readOnly === true, "Consumption view must remain read-only.");
assert(view.dashboardSafe === true, "Consumption view must remain dashboard-safe.");
assert(view.signalCount === 2, "Consumption view signal count must be deduplicated.");
assert(view.signals.join("|") === "authority|routing", "Consumption view signals must be sorted.");
assert(selection.headlineStatus === "attention", "Selection must expose overall status.");
assert(selection.headlineSeverity === "warning", "Selection must expose severity.");
assert(proof.pass === true, "Dashboard consumption proof must pass.");

console.log("phase136 governance dashboard consumption smoke PASS");
