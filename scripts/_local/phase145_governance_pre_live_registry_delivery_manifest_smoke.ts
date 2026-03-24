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
  buildGovernancePreLiveRegistryHandoffEnvelope,
  buildGovernancePreLiveRegistryDeliveryManifest,
  selectGovernancePreLiveRegistryDeliveryManifest,
  proveGovernancePreLiveRegistryDeliveryManifest
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
  ts: 145001
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
const envelope = buildGovernancePreLiveRegistryHandoffEnvelope(contractPackage);
const manifest = buildGovernancePreLiveRegistryDeliveryManifest(envelope);
const selection = selectGovernancePreLiveRegistryDeliveryManifest(manifest);
const proof = proveGovernancePreLiveRegistryDeliveryManifest();

assert(manifest.readOnly === true, "Manifest must remain read-only.");
assert(manifest.dashboardSafe === true, "Manifest must remain dashboard-safe.");
assert(manifest.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
assert(manifest.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
assert(manifest.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(manifest.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(manifest.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(manifest.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(manifest.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(manifest.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(manifest.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(manifest.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(manifest.manifestStatus === "prepared", "Manifest status must evaluate to prepared.");
assert(manifest.deliveryReady === true, "Manifest must evaluate to true.");
assert(selection.signalCount === 2, "Manifest selection must preserve signal count.");
assert(proof.pass === true, "Governance pre-live delivery manifest proof must pass.");

console.log("phase145 governance pre-live registry delivery manifest smoke PASS");
