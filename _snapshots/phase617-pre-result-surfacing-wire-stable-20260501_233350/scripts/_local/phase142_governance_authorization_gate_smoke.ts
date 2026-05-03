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
  buildGovernanceAuthorizationGate,
  selectGovernanceAuthorizationGate,
  proveGovernanceAuthorizationGate
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
  ts: 142001
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
const gate = buildGovernanceAuthorizationGate(decision);
const selection = selectGovernanceAuthorizationGate(gate);
const proof = proveGovernanceAuthorizationGate();

assert(gate.readOnly === true, "Authorization gate must remain read-only.");
assert(gate.dashboardSafe === true, "Authorization gate must remain dashboard-safe.");
assert(gate.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(gate.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(gate.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(gate.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(gate.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(gate.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(gate.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(gate.gateStatus === "open", "Authorization gate status must evaluate to open.");
assert(gate.authorizationEligible === true, "Authorization gate must evaluate to true.");
assert(selection.signalCount === 2, "Authorization gate selection must preserve signal count.");
assert(proof.pass === true, "Governance authorization gate proof must pass.");

console.log("phase142 governance authorization gate smoke PASS");
