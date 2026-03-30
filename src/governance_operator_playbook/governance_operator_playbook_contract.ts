export const GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter manual source semantics",
  "cannot alter playbook ordering determinism",
] as const);

export function getGovernanceOperatorPlaybookLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_PLAYBOOK_LAYER_GUARANTEES;
}
