function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceReportHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance report: ${decisionId} (${decision})`;
}

export function formatGovernanceReportDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceReportPolicy(policyRoute: string | null): string {
  return `Policy route: ${policyRoute ?? "none"}`;
}

export function formatGovernanceReportInvariants(
  invariants: readonly string[],
): string {
  return `Invariants triggered: ${formatList(invariants)}`;
}

export function formatGovernanceReportStages(
  stages: readonly string[],
): string {
  return `Completed stages: ${formatList(stages)}`;
}

export function formatGovernanceReportProvenance(
  provenanceSummary: string,
): string {
  return `Provenance: ${provenanceSummary}`;
}
