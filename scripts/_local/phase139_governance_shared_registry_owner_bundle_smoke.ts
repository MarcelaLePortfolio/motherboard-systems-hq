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
  ts: 139001
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

assert(normalizedOwnerBundle.readOnly === true, "Owner bundle must remain read-only.");
assert(normalizedOwnerBundle.dashboardSafe === true, "Owner bundle must remain dashboard-safe.");
assert(normalizedOwnerBundle.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(normalizedOwnerBundle.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(normalizedOwnerBundle.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(normalizedOwnerBundle.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(normalizedOwnerBundle.registryExport.registration.payload.signalCount === 2, "Normalized owner bundle signal count must be deduplicated.");
assert(normalizedOwnerBundle.registryExport.registration.payload.signals.join("|") === "authority|routing", "Normalized owner bundle signals must be sorted.");
assert(selection.signalCount === 2, "Owner bundle selection must preserve signal count.");
assert(proof.pass === true, "Governance shared registry owner bundle proof must pass.");

console.log("phase139 governance shared registry owner bundle smoke PASS");
