export const GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter map source semantics",
  "cannot alter atlas ordering determinism",
] as const);

export function getGovernanceOperatorAtlasLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES;
}
