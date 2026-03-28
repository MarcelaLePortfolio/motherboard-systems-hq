function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorPacketHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator packet: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorPacketDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorPacketPolicy(
  policyRoute: string | null,
): string {
  return `Policy route: ${policyRoute ?? "none"}`;
}

export function formatGovernanceOperatorPacketInvariants(
  invariants: readonly string[],
): string {
  return `Invariants: ${formatList(invariants)}`;
}

export function formatGovernanceOperatorPacketStages(
  stages: readonly string[],
): string {
  return `Stages: ${formatList(stages)}`;
}

export function formatGovernanceOperatorPacketArtifacts(
  explanationAvailable: boolean,
  auditRecorded: boolean,
): string {
  return `Artifacts: explanation=${explanationAvailable ? "yes" : "no"}, audit=${auditRecorded ? "yes" : "no"}`;
}

export function formatGovernanceOperatorPacketCompleteness(
  complete: boolean,
): string {
  return `Packet complete: ${complete ? "yes" : "no"}`;
}
