export const GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter console source semantics",
  "cannot alter handoff ordering determinism",
] as const);

export function getGovernanceOperatorHandoffLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES;
}
