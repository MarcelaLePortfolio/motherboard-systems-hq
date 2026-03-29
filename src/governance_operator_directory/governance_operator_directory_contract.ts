export const GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter registry source semantics",
  "cannot alter directory ordering determinism",
] as const);

export function getGovernanceOperatorDirectoryLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES;
}
