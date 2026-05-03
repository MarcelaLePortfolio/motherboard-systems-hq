function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorSessionHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator session: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorSessionDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorSessionSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorSessionReadiness(
  ready: boolean,
): string {
  return `Session ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorSessionCompleteness(
  complete: boolean,
): string {
  return `Session complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorSessionVersion(
  version: string,
): string {
  return `Session version: ${version}`;
}
