export const GOVERNANCE_DIGEST_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter reporting source semantics",
] as const);

export function getGovernanceDigestLayerGuarantees(): readonly string[] {
  return GOVERNANCE_DIGEST_LAYER_GUARANTEES;
}
