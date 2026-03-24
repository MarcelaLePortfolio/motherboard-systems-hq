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
  ts: 138001
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

assert(normalizedExport.readOnly === true, "Runtime registry export must remain read-only.");
assert(normalizedExport.dashboardSafe === true, "Runtime registry export must remain dashboard-safe.");
assert(normalizedExport.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(normalizedExport.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(normalizedExport.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(normalizedExport.registration.payload.signalCount === 2, "Normalized export signal count must be deduplicated.");
assert(normalizedExport.registration.payload.signals.join("|") === "authority|routing", "Normalized export signals must be sorted.");
assert(selection.signalCount === 2, "Registry export selection must preserve signal count.");
assert(proof.pass === true, "Governance runtime registry export proof must pass.");

console.log("phase138 governance runtime registry export smoke PASS");
