function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorDictionaryHeadline(): string {
  return "Governance operator dictionary";
}

export function formatGovernanceOperatorDictionaryTerms(
  terms: readonly string[],
): string {
  return `Terms: ${formatList(terms)}`;
}

export function formatGovernanceOperatorDictionaryReadiness(
  ready: boolean,
): string {
  return `Dictionary ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorDictionaryCompleteness(
  complete: boolean,
): string {
  return `Dictionary complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorDictionaryVersion(
  version: string,
): string {
  return `Dictionary version: ${version}`;
}
