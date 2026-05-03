function formatList(values: readonly string[]): string {
  return values.length ? values.join(", ") : "none";
}

export function formatGovernanceOperatorGlossaryHeadline(): string {
  return "Governance operator glossary";
}

export function formatGovernanceOperatorGlossaryTerms(
  terms: readonly string[],
): string {
  return `Terms: ${formatList(terms)}`;
}

export function formatGovernanceOperatorGlossaryReadiness(
  ready: boolean,
): string {
  return `Glossary ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorGlossaryCompleteness(
  complete: boolean,
): string {
  return `Glossary complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorGlossaryVersion(
  version: string,
): string {
  return `Glossary version: ${version}`;
}
