export const GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter record source semantics",
  "cannot alter logbook ordering determinism",
] as const);

export function getGovernanceOperatorLogbookLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_LOGBOOK_LAYER_GUARANTEES;
}
