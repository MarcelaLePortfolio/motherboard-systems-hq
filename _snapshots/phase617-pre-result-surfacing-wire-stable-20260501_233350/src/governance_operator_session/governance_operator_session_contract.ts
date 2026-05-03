export const GOVERNANCE_OPERATOR_SESSION_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter handoff source semantics",
  "cannot alter session ordering determinism",
] as const);

export function getGovernanceOperatorSessionLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_SESSION_LAYER_GUARANTEES;
}
