export const GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter bundle source semantics",
  "cannot alter export ordering determinism",
] as const);

export function getGovernanceOperatorExportLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_EXPORT_LAYER_GUARANTEES;
}
