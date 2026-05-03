export const GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter atlas source semantics",
  "cannot alter ledger ordering determinism",
] as const);

export function getGovernanceOperatorLedgerLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_LEDGER_LAYER_GUARANTEES;
}
