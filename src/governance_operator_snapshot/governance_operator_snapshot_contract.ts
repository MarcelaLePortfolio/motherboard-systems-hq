export const GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter session source semantics",
  "cannot alter snapshot ordering determinism",
] as const);

export function getGovernanceOperatorSnapshotLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_SNAPSHOT_LAYER_GUARANTEES;
}
