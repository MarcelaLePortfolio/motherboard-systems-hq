import type { GovernanceTraceabilityRecord } from "./governance_traceability_model";

function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatDecisionTraceHeadline(
  record: GovernanceTraceabilityRecord,
): string {
  return `Decision trace: ${record.decision_id} (${record.decision})`;
}

export function formatDecisionTraceStages(
  record: GovernanceTraceabilityRecord,
): string {
  return `Completed stages: ${formatList(record.completed_stages)}`;
}

export function formatDecisionTracePolicy(
  record: GovernanceTraceabilityRecord,
): string {
  return `Policy route: ${record.policy_route ?? "none"}`;
}

export function formatDecisionTraceInvariants(
  record: GovernanceTraceabilityRecord,
): string {
  return `Invariants triggered: ${formatList(record.invariants_triggered)}`;
}

export function formatDecisionTraceProvenance(
  record: GovernanceTraceabilityRecord,
): string {
  return `Provenance: ${record.provenance_summary}`;
}
