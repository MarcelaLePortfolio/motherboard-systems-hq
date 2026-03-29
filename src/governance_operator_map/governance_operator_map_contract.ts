export const GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter manifest index source semantics",
  "cannot alter map ordering determinism",
] as const);

export function getGovernanceOperatorMapLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES;
}
