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
  buildGovernanceFinalPreLiveRegistryContractPackage,
  selectGovernanceFinalPreLiveRegistryContractPackage,
  proveGovernanceFinalPreLiveRegistryContractPackage
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
  ts: 143001
});

const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
const packagedSnapshot = packageGovernanceCognitionSnapshot(normalizedSnapshot);
const view = buildGovernanceDashboardConsumptionView(packagedSnapshot);
const registration = registerGovernanceDashboardContract(view);
const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);
const registryExport = buildGovernanceRuntimeRegistryExport(normalizedRegistration);
const normalizedExport = normalizeGovernanceRuntimeRegistryExport(registryExport);
const ownerBundle = buildGovernanceSharedRegistryOwnerBundle(normalizedExport);
const normalizedOwnerBundle = normalizeGovernanceSharedRegistryOwnerBundle(ownerBundle);
const readiness = buildGovernanceLiveRegistryWiringReadiness(normalizedOwnerBundle);
const decision = buildGovernanceLiveWiringDecision(readiness);
const gate = buildGovernanceAuthorizationGate(decision);
const contractPackage = buildGovernanceFinalPreLiveRegistryContractPackage(gate);
const selection = selectGovernanceFinalPreLiveRegistryContractPackage(contractPackage);
const proof = proveGovernanceFinalPreLiveRegistryContractPackage();

assert(contractPackage.readOnly === true, "Contract package must remain read-only.");
assert(contractPackage.dashboardSafe === true, "Contract package must remain dashboard-safe.");
assert(contractPackage.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(contractPackage.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(contractPackage.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(contractPackage.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(contractPackage.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(contractPackage.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(contractPackage.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(contractPackage.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(contractPackage.packageStatus === "prepared", "Contract package status must evaluate to prepared.");
assert(contractPackage.handoffEligible === true, "Contract package must evaluate to true.");
assert(selection.signalCount === 2, "Contract package selection must preserve signal count.");
assert(proof.pass === true, "Governance final pre-live contract package proof must pass.");

console.log("phase143 governance final pre-live registry contract package smoke PASS");
