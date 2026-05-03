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
  ts: 141001
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

assert(decision.readOnly === true, "Decision must remain read-only.");
assert(decision.dashboardSafe === true, "Decision must remain dashboard-safe.");
assert(decision.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(decision.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(decision.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(decision.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(decision.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(decision.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(decision.decisionStatus === "eligible", "Decision status must evaluate to eligible.");
assert(decision.eligibleForExplicitLiveWiring === true, "Decision must evaluate to true.");
assert(selection.signalCount === 2, "Decision selection must preserve signal count.");
assert(proof.pass === true, "Governance live wiring decision proof must pass.");

console.log("phase141 governance live wiring decision smoke PASS");
