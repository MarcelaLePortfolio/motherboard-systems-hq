export const GOVERNANCE_VISIBILITY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision",
  "cannot affect routing",
  "cannot affect policy result",
  "cannot change explanation",
  "cannot change audit log",
] as const);

export function getGovernanceVisibilityLayerGuarantees(): readonly string[] {
  return GOVERNANCE_VISIBILITY_LAYER_GUARANTEES;
}
