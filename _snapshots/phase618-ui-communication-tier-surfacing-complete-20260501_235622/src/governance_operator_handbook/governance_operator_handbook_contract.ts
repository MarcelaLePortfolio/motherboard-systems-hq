export const GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter playbook source semantics",
  "cannot alter handbook ordering determinism",
] as const);

export function getGovernanceOperatorHandbookLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES;
}
