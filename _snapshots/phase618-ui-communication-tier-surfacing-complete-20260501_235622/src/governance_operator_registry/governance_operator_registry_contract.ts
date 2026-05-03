export const GOVERNANCE_OPERATOR_REGISTRY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter ledger source semantics",
  "cannot alter registry ordering determinism",
] as const);

export function getGovernanceOperatorRegistryLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_REGISTRY_LAYER_GUARANTEES;
}
