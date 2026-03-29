export const GOVERNANCE_OPERATOR_INDEX_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter catalog source semantics",
  "cannot alter index ordering determinism",
] as const);

export function getGovernanceOperatorIndexLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_INDEX_LAYER_GUARANTEES;
}
