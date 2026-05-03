export const GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter briefing source semantics",
  "cannot alter console ordering determinism",
] as const);

export function getGovernanceOperatorConsoleLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_CONSOLE_LAYER_GUARANTEES;
}
