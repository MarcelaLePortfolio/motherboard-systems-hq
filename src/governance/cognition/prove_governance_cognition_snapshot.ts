/**
 * Phase 135 — Governance Cognition Snapshot Proof
 *
 * Deterministic proof surface for snapshot packaging invariants.
 * No test runner dependency required.
 */

import { buildGovernanceCognitionSnapshot } from "./build_governance_cognition_snapshot";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";
import { packageGovernanceCognitionSnapshot } from "./package_governance_cognition_snapshot";

export interface GovernanceCognitionSnapshotProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly normalizedSignalOrder: readonly string[];
  readonly packagedKind: "governance-cognition-snapshot";
  readonly packagedVersion: 1;
  readonly overallStatus: string;
  readonly severity: string;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceCognitionSnapshot(): GovernanceCognitionSnapshotProof {
  const built = buildGovernanceCognitionSnapshot({
    routingStatus: "attention",
    authorityStatus: "stable",
    registryStatus: "review",
    signals: ["registry", "authority", "registry", "routing"],
    ts: 135000
  });

  const normalized = normalizeGovernanceSnapshot(built);
  const packaged = packageGovernanceCognitionSnapshot(normalized);

  assert(normalized.deterministic === true, "Normalized snapshot must remain deterministic.");
  assert(packaged.operatorSafe === true, "Packaged snapshot must be operator-safe.");
  assert(packaged.dashboardReady === true, "Packaged snapshot must be dashboard-ready.");
  assert(packaged.snapshot.signals.join("|") === "authority|registry|routing", "Signals must be deduplicated and sorted.");
  assert(packaged.snapshot.overallStatus === "review", "Overall status must preserve deterministic precedence.");
  assert(packaged.snapshot.severity === "elevated", "Severity must preserve deterministic precedence.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    normalizedSignalOrder: packaged.snapshot.signals,
    packagedKind: packaged.kind,
    packagedVersion: packaged.version,
    overallStatus: packaged.snapshot.overallStatus,
    severity: packaged.snapshot.severity
  });
}
