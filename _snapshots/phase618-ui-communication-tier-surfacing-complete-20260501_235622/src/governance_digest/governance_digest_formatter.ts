function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceDigestHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance digest: ${decisionId} (${decision})`;
}

export function formatGovernanceDigestDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceDigestPolicy(policyRoute: string | null): string {
  return `Policy route: ${policyRoute ?? "none"}`;
}

export function formatGovernanceDigestInvariants(
  invariants: readonly string[],
): string {
  return `Invariants: ${formatList(invariants)}`;
}

export function formatGovernanceDigestStages(
  stages: readonly string[],
): string {
  return `Stages: ${formatList(stages)}`;
}

export function formatGovernanceDigestArtifacts(
  explanationAvailable: boolean,
  auditRecorded: boolean,
): string {
  return `Artifacts: explanation=${explanationAvailable ? "yes" : "no"}, audit=${auditRecorded ? "yes" : "no"}`;
}

export function formatGovernanceDigestProvenance(
  provenanceSummary: string,
): string {
  return `Provenance: ${provenanceSummary}`;
}
