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
  buildGovernanceFinalPreLiveRegistryArchiveRecord,
  buildGovernanceFinalPreLiveRegistrySummaryCapsule,
  selectGovernanceFinalPreLiveRegistrySummaryCapsule,
  proveGovernanceFinalPreLiveRegistrySummaryCapsule
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
  ts: 148001
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
const archiveRecord = buildGovernanceFinalPreLiveRegistryArchiveRecord(receipt);
const capsule = buildGovernanceFinalPreLiveRegistrySummaryCapsule(archiveRecord);
const selection = selectGovernanceFinalPreLiveRegistrySummaryCapsule(capsule);
const proof = proveGovernanceFinalPreLiveRegistrySummaryCapsule();

assert(capsule.readOnly === true, "Capsule must remain read-only.");
assert(capsule.dashboardSafe === true, "Capsule must remain dashboard-safe.");
assert(capsule.capsuleKey === "governance-final-pre-live-registry-summary-capsule", "Capsule key must match.");
assert(capsule.archiveKey === "governance-final-pre-live-registry-archive-record", "Archive key must match.");
assert(capsule.receiptKey === "governance-final-delivery-receipt", "Receipt key must match.");
assert(capsule.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
assert(capsule.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
assert(capsule.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(capsule.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(capsule.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(capsule.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(capsule.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(capsule.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(capsule.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(capsule.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(capsule.capsuleStatus === "summarized", "Capsule status must evaluate to summarized.");
assert(capsule.summaryReady === true, "Capsule must evaluate to true.");
assert(selection.signalCount === 2, "Capsule selection must preserve signal count.");
assert(proof.pass === true, "Governance summary capsule proof must pass.");

console.log("phase148 governance final pre-live registry summary capsule smoke PASS");
