import type { GovernanceVisibilityRecord } from "./governance_visibility_model";

function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatDecision(record: GovernanceVisibilityRecord): string {
  return `Decision: ${record.decision}`;
}

export function formatInvariantSummary(record: GovernanceVisibilityRecord): string {
  return `Invariants triggered: ${formatList(record.invariants_triggered)}`;
}

export function formatPolicySummary(record: GovernanceVisibilityRecord): string {
  return `Policy matched: ${record.policy_matched ?? "none"}`;
}

export function formatExplanationPresence(record: GovernanceVisibilityRecord): string {
  return `Explanation available: ${record.explanation_available ? "yes" : "no"}`;
}

export function formatAuditPresence(record: GovernanceVisibilityRecord): string {
  return `Audit recorded: ${record.audit_recorded ? "yes" : "no"}`;
}
