/**
 * Phase 142 — Governance Authorization Gate Builder
 *
 * Pure deterministic adapter from explicit live wiring decision
 * to final pre-execution authorization gate surface.
 */

import type { GovernanceLiveWiringDecision } from "./governance_live_wiring_decision";
import type {
  GovernanceAuthorizationGate,
  GovernanceAuthorizationGateStatus
} from "./governance_authorization_gate";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

function deriveGateStatus(
  decision: GovernanceLiveWiringDecision
): GovernanceAuthorizationGateStatus {
  return decision.eligibleForExplicitLiveWiring ? "open" : "closed";
}

export function buildGovernanceAuthorizationGate(
  decision: GovernanceLiveWiringDecision
): GovernanceAuthorizationGate {
  const gateStatus = deriveGateStatus(decision);
  const authorizationEligible = gateStatus === "open";

  const authorizationReasons = uniqueSorted([
    ...decision.decisionReasons,
    gateStatus,
    authorizationEligible ? "authorization-eligible" : "authorization-ineligible"
  ]);

  return Object.freeze({
    kind: "governance-authorization-gate" as const,
    version: 1 as const,

    gateKey: "governance-authorization-gate" as const,
    decisionKey: decision.decisionKey,
    readinessKey: decision.readinessKey,
    ownerKey: decision.ownerKey,
    exportKey: decision.exportKey,
    registryKey: decision.registryKey,
    contractId: decision.contractId,

    channel: decision.channel,
    surface: decision.surface,
    mode: decision.mode,

    ts: decision.ts,

    gateStatus,
    authorizationEligible,
    authorizationReasons,

    decision,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
