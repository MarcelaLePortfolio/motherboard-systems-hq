export const GOVERNANCE_OPERATOR_GUIDE_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter directory source semantics",
  "cannot alter guide ordering determinism",
] as const);

export function getGovernanceOperatorGuideLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_GUIDE_LAYER_GUARANTEES;
}
