export const GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter index source semantics",
  "cannot alter manifest index ordering determinism",
] as const);

export function getGovernanceOperatorManifestIndexLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES;
}
