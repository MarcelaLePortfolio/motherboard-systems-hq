export const GOVERNANCE_OPERATOR_ARCHIVE_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter export source semantics",
  "cannot alter archive ordering determinism",
] as const);

export function getGovernanceOperatorArchiveLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_ARCHIVE_LAYER_GUARANTEES;
}
