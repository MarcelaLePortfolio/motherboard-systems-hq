export const GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
] as const);

export function getGovernanceTraceabilityLayerGuarantees(): readonly string[] {
  return GOVERNANCE_TRACEABILITY_LAYER_GUARANTEES;
}
