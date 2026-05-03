/**
 * Phase 144 — Governance Pre-Live Registry Handoff Envelope Builder
 *
 * Pure deterministic adapter from final pre-live registry contract package
 * to final handoff wrapper surface.
 */

import type { GovernanceFinalPreLiveRegistryContractPackage } from "./governance_final_pre_live_registry_contract_package";
import type { GovernancePreLiveRegistryHandoffEnvelope } from "./governance_pre_live_registry_handoff_envelope";

function uniqueSorted(values: readonly string[]): readonly string[] {
  return Object.freeze([...new Set(values)].sort());
}

export function buildGovernancePreLiveRegistryHandoffEnvelope(
  contractPackage: GovernanceFinalPreLiveRegistryContractPackage
): GovernancePreLiveRegistryHandoffEnvelope {
  const handoffReady = contractPackage.handoffEligible === true;

  const envelopeReasons = uniqueSorted([
    ...contractPackage.packageReasons,
    "handoff-envelope-wrapped",
    handoffReady ? "handoff-ready" : "handoff-not-ready"
  ]);

  return Object.freeze({
    kind: "governance-pre-live-registry-handoff-envelope" as const,
    version: 1 as const,

    envelopeKey: "governance-pre-live-registry-handoff-envelope" as const,
    packageKey: contractPackage.packageKey,
    gateKey: contractPackage.gateKey,
    decisionKey: contractPackage.decisionKey,
    readinessKey: contractPackage.readinessKey,
    ownerKey: contractPackage.ownerKey,
    exportKey: contractPackage.exportKey,
    registryKey: contractPackage.registryKey,
    contractId: contractPackage.contractId,

    channel: contractPackage.channel,
    surface: contractPackage.surface,
    mode: contractPackage.mode,

    ts: contractPackage.ts,

    envelopeStatus: "wrapped" as const,
    handoffReady,
    envelopeReasons,

    contractPackage,

    operatorSafe: true as const,
    dashboardSafe: true as const,
    readOnly: true as const,
    deterministic: true as const
  });
}
