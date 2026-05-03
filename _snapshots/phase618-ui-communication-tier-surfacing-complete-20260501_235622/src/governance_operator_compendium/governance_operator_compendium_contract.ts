export const GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter handbook source semantics",
  "cannot alter compendium ordering determinism",
] as const);

export function getGovernanceOperatorCompendiumLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES;
}
