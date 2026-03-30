function formatList(values: readonly string[]): string {
  return values.length > 0 ? values.join(", ") : "none";
}

export function formatGovernanceOperatorLexiconHeadline(): string {
  return "Governance operator lexicon";
}

export function formatGovernanceOperatorLexiconTerms(
  terms: readonly string[],
): string {
  return `Terms: ${formatList(terms)}`;
}

export function formatGovernanceOperatorLexiconReadiness(
  ready: boolean,
): string {
  return `Lexicon ready: ${ready ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLexiconCompleteness(
  complete: boolean,
): string {
  return `Lexicon complete: ${complete ? "yes" : "no"}`;
}

export function formatGovernanceOperatorLexiconVersion(
  version: string,
): string {
  return `Lexicon version: ${version}`;
}
