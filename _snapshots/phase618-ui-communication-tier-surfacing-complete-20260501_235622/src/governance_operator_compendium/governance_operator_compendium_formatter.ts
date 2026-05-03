function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorCompendiumHeadline(
  decisionId: string,
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Governance operator compendium: ${decisionId} (${decision})`;
}

export function formatGovernanceOperatorCompendiumDecision(
  decision: "ALLOW" | "WARN" | "BLOCK",
): string {
  return `Decision: ${decision}`;
}

export function formatGovernanceOperatorCompendiumSections(
  sectionTitles: readonly string[],
): string {
  return `Sections: ${formatList(sectionTitles)}`;
}

export function formatGovernanceOperatorCompendiumReadiness(
  ready: boolean,
): string {
  return `Compendium ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorCompendiumCompleteness(
  complete: boolean,
): string {
  return `Compendium complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorCompendiumVersion(
  version: string,
): string {
  return `Compendium version: ${version}`;
}
