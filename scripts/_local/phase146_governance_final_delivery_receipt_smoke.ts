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
  buildGovernanceFinalDeliveryReceipt,
  selectGovernanceFinalDeliveryReceipt,
  proveGovernanceFinalDeliveryReceipt
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
  ts: 146001
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
const receipt = buildGovernanceFinalDeliveryReceipt(manifest);
const selection = selectGovernanceFinalDeliveryReceipt(receipt);
const proof = proveGovernanceFinalDeliveryReceipt();

assert(receipt.readOnly === true, "Receipt must remain read-only.");
assert(receipt.dashboardSafe === true, "Receipt must remain dashboard-safe.");
assert(receipt.receiptKey === "governance-final-delivery-receipt", "Receipt key must match.");
assert(receipt.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
assert(receipt.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
assert(receipt.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(receipt.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(receipt.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(receipt.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(receipt.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(receipt.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(receipt.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(receipt.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(receipt.receiptStatus === "acknowledged", "Receipt status must evaluate to acknowledged.");
assert(receipt.acknowledgementReady === true, "Receipt must evaluate to true.");
assert(selection.signalCount === 2, "Receipt selection must preserve signal count.");
assert(proof.pass === true, "Governance final delivery receipt proof must pass.");

console.log("phase146 governance final delivery receipt smoke PASS");
