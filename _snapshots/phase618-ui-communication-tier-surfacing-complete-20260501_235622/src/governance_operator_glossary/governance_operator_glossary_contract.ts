export const GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter reference semantics",
  "cannot alter glossary ordering determinism",
] as const);

export function getGovernanceOperatorGlossaryLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES;
}
