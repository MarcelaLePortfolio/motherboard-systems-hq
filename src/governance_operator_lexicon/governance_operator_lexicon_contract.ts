export const GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter glossary semantics",
  "cannot alter lexicon ordering determinism",
] as const);

export function getGovernanceOperatorLexiconLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES;
}
