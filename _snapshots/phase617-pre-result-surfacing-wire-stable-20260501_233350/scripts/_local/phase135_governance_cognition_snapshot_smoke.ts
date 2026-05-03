import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  proveGovernanceCognitionSnapshot
} from "../../src/governance/cognition";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

const built = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "attention",
  registryStatus: "stable",
  signals: ["authority", "routing", "authority"],
  ts: 135001
});

const normalized = normalizeGovernanceSnapshot(built);
const packaged = packageGovernanceCognitionSnapshot(normalized);
const proof = proveGovernanceCognitionSnapshot();

assert(built.deterministic === true, "Built snapshot must be deterministic.");
assert(normalized.signals.join("|") === "authority|authority|routing", "Normalized snapshot must preserve sorted signal order.");
assert(packaged.snapshot.signals.join("|") === "authority|routing", "Packaged snapshot must expose deduplicated sorted signals.");
assert(packaged.operatorSafe === true, "Packaged snapshot must be operator-safe.");
assert(packaged.dashboardReady === true, "Packaged snapshot must be dashboard-ready.");
assert(proof.pass === true, "Snapshot proof must pass.");

console.log("phase135 governance cognition snapshot smoke PASS");
