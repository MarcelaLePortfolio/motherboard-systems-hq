export const GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter manifest source semantics",
  "cannot alter briefing ordering determinism",
] as const);

export function getGovernanceOperatorBriefingLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_BRIEFING_LAYER_GUARANTEES;
}
