/**
 * Phase 137 — Governance Dashboard Contract Registration Proof
 *
 * Deterministic proof surface for contract registration preparation.
 */

import { buildGovernanceCognitionSnapshot } from "./build_governance_cognition_snapshot";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";
import { packageGovernanceCognitionSnapshot } from "./package_governance_cognition_snapshot";
import { buildGovernanceDashboardConsumptionView } from "./build_governance_dashboard_consumption_view";
import { registerGovernanceDashboardContract } from "./register_governance_dashboard_contract";
import { normalizeGovernanceDashboardContractRegistration } from "./normalize_governance_dashboard_contract_registration";

export interface GovernanceDashboardContractRegistrationProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly contractId: "governance.dashboard.consumption";
  readonly registryKey: "governance-dashboard-consumption";
  readonly signalCount: number;
  readonly signals: readonly string[];
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceDashboardContractRegistration(): GovernanceDashboardContractRegistrationProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["registry", "authority", "routing", "authority"],
    ts: 137000
  });

  const normalizedSnapshot = normalizeGovernanceSnapshot(snapshot);
  const packaged = packageGovernanceCognitionSnapshot(normalizedSnapshot);
  const view = buildGovernanceDashboardConsumptionView(packaged);
  const registration = registerGovernanceDashboardContract(view);
  const normalizedRegistration = normalizeGovernanceDashboardContractRegistration(registration);

  assert(
    normalizedRegistration.kind === "governance-dashboard-contract-registration",
    "Registration kind must match contract."
  );
  assert(
    normalizedRegistration.contractId === "governance.dashboard.consumption",
    "Contract id must match."
  );
  assert(
    normalizedRegistration.registryKey === "governance-dashboard-consumption",
    "Registry key must match."
  );
  assert(normalizedRegistration.readOnly === true, "Registration must remain read-only.");
  assert(normalizedRegistration.dashboardSafe === true, "Registration must remain dashboard-safe.");
  assert(normalizedRegistration.payload.signals.join("|") === "authority|registry|routing", "Signals must be deduplicated and sorted.");
  assert(normalizedRegistration.payload.signalCount === 3, "Signal count must reflect normalized unique signals.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    contractId: normalizedRegistration.contractId,
    registryKey: normalizedRegistration.registryKey,
    signalCount: normalizedRegistration.payload.signalCount,
    signals: normalizedRegistration.payload.signals,
    readOnly: true as const
  });
}
