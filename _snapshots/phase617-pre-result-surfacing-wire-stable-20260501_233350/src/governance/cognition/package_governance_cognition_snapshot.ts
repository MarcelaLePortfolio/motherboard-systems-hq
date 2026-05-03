/**
 * Phase 135 — Governance Cognition Snapshot Packaging
 *
 * Operator-safe deterministic packaging layer for dashboard-safe consumption.
 * No UI coupling.
 * No execution coupling.
 * No runtime mutation.
 */

import type { GovernanceCognitionSnapshot } from "./governance_cognition_snapshot_contract";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";

export interface OperatorSafeGovernanceCognitionPackage {
  readonly kind: "governance-cognition-snapshot";
  readonly version: 1;
  readonly snapshot: GovernanceCognitionSnapshot;
  readonly operatorSafe: true;
  readonly dashboardReady: true;
  readonly deterministic: true;
}

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function packageGovernanceCognitionSnapshot(
  snapshot: GovernanceCognitionSnapshot
): OperatorSafeGovernanceCognitionPackage {
  const normalized = normalizeGovernanceSnapshot(snapshot);

  const operatorSafeSnapshot: GovernanceCognitionSnapshot = Object.freeze({
    ...normalized,
    signals: uniqueSorted(normalized.signals),
    deterministic: true as const
  });

  return Object.freeze({
    kind: "governance-cognition-snapshot" as const,
    version: 1 as const,
    snapshot: operatorSafeSnapshot,
    operatorSafe: true as const,
    dashboardReady: true as const,
    deterministic: true as const
  });
}
