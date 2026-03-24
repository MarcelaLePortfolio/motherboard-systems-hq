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
  selectGovernancePreLiveRegistryHandoffEnvelope,
  proveGovernancePreLiveRegistryHandoffEnvelope
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
  ts: 144001
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
const selection = selectGovernancePreLiveRegistryHandoffEnvelope(envelope);
const proof = proveGovernancePreLiveRegistryHandoffEnvelope();

assert(envelope.readOnly === true, "Envelope must remain read-only.");
assert(envelope.dashboardSafe === true, "Envelope must remain dashboard-safe.");
assert(envelope.envelopeKey === "governance-pre-live-registry-handoff-envelope", "Envelope key must match.");
assert(envelope.packageKey === "governance-final-pre-live-registry-contract-package", "Package key must match.");
assert(envelope.gateKey === "governance-authorization-gate", "Gate key must match.");
assert(envelope.decisionKey === "governance-live-wiring-decision", "Decision key must match.");
assert(envelope.readinessKey === "governance-live-registry-wiring-readiness", "Readiness key must match.");
assert(envelope.ownerKey === "shared-runtime-registry-owner", "Owner key must match.");
assert(envelope.exportKey === "governance-runtime-registry-export", "Export key must match.");
assert(envelope.registryKey === "governance-dashboard-consumption", "Registry key must match.");
assert(envelope.contractId === "governance.dashboard.consumption", "Contract id must match.");
assert(envelope.envelopeStatus === "wrapped", "Envelope status must evaluate to wrapped.");
assert(envelope.handoffReady === true, "Envelope must evaluate to true.");
assert(selection.signalCount === 2, "Envelope selection must preserve signal count.");
assert(proof.pass === true, "Governance pre-live handoff envelope proof must pass.");

console.log("phase144 governance pre-live registry handoff envelope smoke PASS");
