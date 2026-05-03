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
  selectGovernanceFinalPreLiveRegistryArchiveRecord,
  proveGovernanceFinalPreLiveRegistryArchiveRecord
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
  ts: 147001
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
const selection = selectGovernanceFinalPreLiveRegistryArchiveRecord(archiveRecord);
const proof = proveGovernanceFinalPreLiveRegistryArchiveRecord();

assert(archiveRecord.readOnly === true, "Archive record must remain read-only.");
assert(archiveRecord.dashboardSafe === true, "Archive record must remain dashboard-safe.");
assert(archiveRecord.archiveKey === "governance-final-pre-live-registry-archive-record", "Archive key must match.");
assert(archiveRecord.receiptKey === "governance-final-delivery-receipt", "Receipt key must match.");
assert(archiveRecord.manifestKey === "governance-pre-live-registry-delivery-manifest", "Manifest key must match.");
assert(archiveRecord.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
assert(archiveRecord.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(archiveRecord.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(archiveRecord.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(archiveRecord.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(archiveRecord.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(archiveRecord.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(archiveRecord.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(archiveRecord.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(archiveRecord.archiveStatus === "recorded", "Archive status must evaluate to recorded.");
assert(archiveRecord.archivalReady === true, "Archive record must evaluate to true.");
assert(selection.signalCount === 2, "Archive selection must preserve signal count.");
assert(proof.pass === true, "Governance archive record proof must pass.");

console.log("phase147 governance final pre-live registry archive record smoke PASS");
