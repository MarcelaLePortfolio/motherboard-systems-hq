/**
 * Phase 136 — Governance Dashboard Consumption Proof
 *
 * Deterministic proof surface for read-only dashboard consumption preparation.
 */

import { buildGovernanceCognitionSnapshot } from "./build_governance_cognition_snapshot";
import { normalizeGovernanceSnapshot } from "./normalize_governance_snapshot";
import { packageGovernanceCognitionSnapshot } from "./package_governance_cognition_snapshot";
import { buildGovernanceDashboardConsumptionView } from "./build_governance_dashboard_consumption_view";
import { selectGovernanceDashboardConsumptionView } from "./select_governance_dashboard_consumption_view";

export interface GovernanceDashboardConsumptionProof {
  readonly pass: true;
  readonly deterministic: true;
  readonly overallStatus: string;
  readonly severity: string;
  readonly signalCount: number;
  readonly signals: readonly string[];
  readonly readOnly: true;
}

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) {
    throw new Error(message);
  }
}

export function proveGovernanceDashboardConsumptionView(): GovernanceDashboardConsumptionProof {
  const snapshot = buildGovernanceCognitionSnapshot({
    routingStatus: "stable",
    authorityStatus: "review",
    registryStatus: "attention",
    signals: ["authority", "registry", "authority", "routing"],
    ts: 136000
  });

  const normalized = normalizeGovernanceSnapshot(snapshot);
  const packaged = packageGovernanceCognitionSnapshot(normalized);
  const view = buildGovernanceDashboardConsumptionView(packaged);
  const selected = selectGovernanceDashboardConsumptionView(view);

  assert(view.kind === "governance-dashboard-consumption-view", "View kind must match contract.");
  assert(view.dashboardSafe === true, "View must be dashboard-safe.");
  assert(view.readOnly === true, "View must remain read-only.");
  assert(view.signalCount === 3, "Signal count must reflect unique sorted signals.");
  assert(view.signals.join("|") === "authority|registry|routing", "Signals must be deduplicated and sorted.");
  assert(selected.headlineStatus === "review", "Selected status must preserve deterministic precedence.");
  assert(selected.headlineSeverity === "elevated", "Selected severity must preserve deterministic precedence.");

  return Object.freeze({
    pass: true as const,
    deterministic: true as const,
    overallStatus: selected.headlineStatus,
    severity: selected.headlineSeverity,
    signalCount: selected.signalCount,
    signals: view.signals,
    readOnly: true as const
  });
}
