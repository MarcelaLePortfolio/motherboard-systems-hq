export const GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter lexicon semantics",
  "cannot alter dictionary ordering determinism",
] as const);

export function getGovernanceOperatorDictionaryLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES;
}
