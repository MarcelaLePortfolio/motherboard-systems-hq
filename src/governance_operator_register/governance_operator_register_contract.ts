export const GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter logbook source semantics",
  "cannot alter register ordering determinism",
] as const);

export function getGovernanceOperatorRegisterLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES;
}
