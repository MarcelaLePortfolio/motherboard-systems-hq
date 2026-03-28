export const GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter archive source semantics",
  "cannot alter record ordering determinism",
] as const);

export function getGovernanceOperatorRecordLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES;
}
