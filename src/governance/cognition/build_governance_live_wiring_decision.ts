/**
 * Phase 141 — Governance Explicit Live Wiring Decision Builder
 *
 * Pure deterministic adapter from live registry wiring readiness
 * to explicit pre-authorization decision surface.
 */

import type { GovernanceLiveRegistryWiringReadiness } from "./governance_live_registry_wiring_readiness";
import type {
  GovernanceLiveWiringDecision,
  GovernanceLiveWiringDecisionStatus
} from "./governance_live_wiring_decision";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

function deriveDecisionStatus(
  readiness: GovernanceLiveRegistryWiringReadiness
): GovernanceLiveWiringDecisionStatus {
  return readiness.readyForLiveOwnerWiring ? "eligible" : "ineligible";
}

export function buildGovernanceLiveWiringDecision(
  readiness: GovernanceLiveRegistryWiringReadiness
): GovernanceLiveWiringDecision {
  const decisionStatus = deriveDecisionStatus(readiness);
  const eligibleForExplicitLiveWiring = decisionStatus === "eligible";

  const decisionReasons = uniqueSorted([
    ...readiness.readinessReasons,
    decisionStatus,
    eligibleForExplicitLiveWiring ? "explicit-live-wiring-eligible" : "explicit-live-wiring-ineligible"
  ]);

  return Object.freeze({
    kind: "governance-live-wiring-decision" as const,
    version: 1 as const,

    decisionKey: "governance-live-wiring-decision" as const,
    readinessKey: readiness.readinessKey,
    ownerKey: readiness.ownerKey,
    exportKey: readiness.exportKey,
    registryKey: readiness.registryKey,
    contractId: readiness.contractId,

    channel: readiness.channel,
    surface: readiness.surface,
    mode: readiness.mode,

    ts: readiness.ts,

    decisionStatus,
    eligibleForExplicitLiveWiring,
    decisionReasons,

    readiness,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
