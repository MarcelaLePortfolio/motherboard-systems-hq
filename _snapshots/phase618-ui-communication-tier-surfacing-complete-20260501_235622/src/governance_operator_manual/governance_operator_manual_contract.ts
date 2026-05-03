export const GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter guide source semantics",
  "cannot alter manual ordering determinism",
] as const);

export function getGovernanceOperatorManualLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES;
}
