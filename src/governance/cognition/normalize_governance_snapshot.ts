/**
 * Phase 135 — Snapshot Normalization
 *
 * Ensures deterministic structure.
 * Defensive normalization only.
 */

import type { GovernanceCognitionSnapshot } from "./governance_cognition_snapshot_contract";

export function normalizeGovernanceSnapshot(
  snapshot: GovernanceCognitionSnapshot
): GovernanceCognitionSnapshot {

  return Object.freeze({
    ...snapshot,
    signals: Object.freeze(
      [...snapshot.signals].sort()
    ),
    deterministic: true as const
  });
}
