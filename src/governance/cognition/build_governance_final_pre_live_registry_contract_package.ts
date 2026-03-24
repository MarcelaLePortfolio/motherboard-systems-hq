/**
 * Phase 143 — Governance Final Pre-Live Registry Contract Package Builder
 *
 * Pure deterministic adapter from authorization gate
 * to final bundled pre-live registry contract package.
 */

import type { GovernanceAuthorizationGate } from "./governance_authorization_gate";
import type { GovernanceFinalPreLiveRegistryContractPackage } from "./governance_final_pre_live_registry_contract_package";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernanceFinalPreLiveRegistryContractPackage(
  authorizationGate: GovernanceAuthorizationGate
): GovernanceFinalPreLiveRegistryContractPackage {
  const handoffEligible = authorizationGate.authorizationEligible === true;

  const packageReasons = uniqueSorted([
    ...authorizationGate.authorizationReasons,
    "final-contract-package-prepared",
    handoffEligible ? "handoff-eligible" : "handoff-ineligible"
  ]);

  return Object.freeze({
    kind: "governance-final-pre-live-registry-contract-package" as const,
    version: 1 as const,

    packageKey: "governance-final-pre-live-registry-contract-package" as const,
    gateKey: authorizationGate.gateKey,
    decisionKey: authorizationGate.decisionKey,
    readinessKey: authorizationGate.readinessKey,
    ownerKey: authorizationGate.ownerKey,
    exportKey: authorizationGate.exportKey,
    registryKey: authorizationGate.registryKey,
    contractId: authorizationGate.contractId,

    channel: authorizationGate.channel,
    surface: authorizationGate.surface,
    mode: authorizationGate.mode,

    ts: authorizationGate.ts,

    packageStatus: "prepared" as const,
    handoffEligible,
    packageReasons,

    authorizationGate,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
