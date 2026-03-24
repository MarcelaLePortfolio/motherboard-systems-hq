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
  ts: 140001
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

assert(readiness.readOnly === true, "Readiness must remain read-only.");
assert(readiness.dashboardSafe === true, "Readiness must remain dashboard-safe.");
assert(readiness.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(readiness.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(readiness.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(readiness.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(readiness.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(readiness.readyForLiveOwnerWiring === true, "Readiness must evaluate to true.");
assert(selection.signalCount === 2, "Readiness selection must preserve signal count.");
assert(proof.pass === true, "Governance live registry wiring readiness proof must pass.");

console.log("phase140 governance live registry wiring readiness smoke PASS");
