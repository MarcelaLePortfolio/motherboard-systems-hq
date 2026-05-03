export const GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter register source semantics",
  "cannot alter catalog ordering determinism",
] as const);

export function getGovernanceOperatorCatalogLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES;
}
