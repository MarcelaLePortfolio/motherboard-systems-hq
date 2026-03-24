import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  buildGovernanceDashboardConsumptionView,
  registerGovernanceDashboardContract,
  normalizeGovernanceDashboardContractRegistration,
  proveGovernanceDashboardContractRegistration
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
  ts: 137001
});

const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
const view = buildGovernanceDashboardConsumptionView(packaged);
const registration = registerGovernanceDashboardContract(view);
const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
const proof = proveGovernanceDashboardContractRegistration();

assert(normalizedRegistration.readOnly === true, "Registration must remain read-only.");
assert(normalizedRegistration.dashboardSafe === true, "Registration must remain dashboard-safe.");
assert(normalizedRegistration.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(normalizedRegistration.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(normalizedRegistration.payload.signalCount === 2, "Normalized registration signal count must be deduplicated.");
assert(normalizedRegistration.payload.signals.join("|") === "authority|routing", "Normalized registration signals must be sorted.");
assert(proof.pass === true, "Governance dashboard contract registration proof must pass.");

console.log("phase137 governance dashboard contract registration smoke PASS");
