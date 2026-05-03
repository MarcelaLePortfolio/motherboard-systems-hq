export const GOVERNANCE_REPORTING_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
] as const);

export function getGovernanceReportingLayerGuarantees(): readonly string[] {
  return GOVERNANCE_REPORTING_LAYER_GUARANTEES;
}
