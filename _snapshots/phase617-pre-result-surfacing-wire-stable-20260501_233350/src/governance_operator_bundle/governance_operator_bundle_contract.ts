export const GOVERNANCE_OPERATOR_BUNDLE_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter snapshot source semantics",
  "cannot alter bundle ordering determinism",
] as const);

export function getGovernanceOperatorBundleLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_BUNDLE_LAYER_GUARANTEES;
}
