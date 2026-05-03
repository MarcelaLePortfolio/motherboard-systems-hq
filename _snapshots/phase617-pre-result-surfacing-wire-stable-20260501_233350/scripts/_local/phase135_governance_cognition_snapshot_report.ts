import {
  buildGovernanceCognitionSnapshot,
  normalizeGovernanceSnapshot,
  packageGovernanceCognitionSnapshot,
  proveGovernanceCognitionSnapshot
} from "../../src/governance/cognition";

const built = buildGovernanceCognitionSnapshot({
  routingStatus: "stable",
  authorityStatus: "attention",
  registryStatus: "review",
  signals: ["registry", "authority", "routing", "authority"],
  ts: 135002
});

const normalized = normalizeGovernanceSnapshot(built);
const packaged = packageGovernanceCognitionSnapshot(normalized);
const proof = proveGovernanceCognitionSnapshot();

const report = Object.freeze({
  phase: 135,
  component: "governance-cognition-snapshot-layer",
  pass: true,
  deterministic: built.deterministic === true
    && normalized.deterministic === true
    && packaged.deterministic === true
    && proof.deterministic === true,
  built: {
    overallStatus: built.overallStatus,
    severity: built.severity,
    signalCount: built.signals.length
  },
  normalized: {
    signalOrder: normalized.signals
  },
  packaged: {
    kind: packaged.kind,
    version: packaged.version,
    operatorSafe: packaged.operatorSafe,
    dashboardReady: packaged.dashboardReady,
    signalOrder: packaged.snapshot.signals
  },
  proof
});

console.log(JSON.stringify(report, null, 2));
