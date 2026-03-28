export const GOVERNANCE_OPERATOR_MANIFEST_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter packet source semantics",
  "cannot alter manifest ordering determinism",
] as const);

export function getGovernanceOperatorManifestLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_MANIFEST_LAYER_GUARANTEES;
}
