/**
 * Phase 143 — Governance Final Pre-Live Registry Contract Package Selector
 *
 * Read-only deterministic package selection surface.
 */

import type { GovernanceFinalPreLiveRegistryContractPackage } from "./governance_final_pre_live_registry_contract_package";

export interface GovernanceFinalPreLiveRegistryContractPackageSelection {
  readonly packageKey: "governance-final-pre-live-registry-contract-package";
  readonly gateKey: "governance-authorization-gate";
  readonly decisionKey: "governance-live-wiring-decision";
  readonly readinessKey: "governance-live-registry-wiring-readiness";
  readonly ownerKey: "shared-runtime-registry-owner";
  readonly exportKey: "governance-runtime-registry-export";
  readonly registryKey: "governance-dashboard-consumption";
  readonly contractId: "governance.dashboard.consumption";
  readonly packageStatus: "prepared";
  readonly handoffEligible: boolean;
  readonly packageReasonCount: number;
  readonly signalCount: number;
  readonly readOnly: true;
  readonly deterministic: true;
}

export function selectGovernanceFinalPreLiveRegistryContractPackage(
  contractPackage: GovernanceFinalPreLiveRegistryContractPackage
): GovernanceFinalPreLiveRegistryContractPackageSelection {
  return Object.freeze({
    packageKey: contractPackage.packageKey,
    gateKey: contractPackage.gateKey,
    decisionKey: contractPackage.decisionKey,
    readinessKey: contractPackage.readinessKey,
    ownerKey: contractPackage.ownerKey,
    exportKey: contractPackage.exportKey,
    registryKey: contractPackage.registryKey,
    contractId: contractPackage.contractId,
    packageStatus: contractPackage.packageStatus,
    handoffEligible: contractPackage.handoffEligible,
    packageReasonCount: contractPackage.packageReasons.length,
    signalCount: contractPackage.authorizationGate.decision.readiness.ownerBundle.registryExport.registration.payload.signalCount,
    readOnly: true as const,
    deterministic: true as const
  });
}
