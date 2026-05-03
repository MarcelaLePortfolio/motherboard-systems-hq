export const GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES = Object.freeze([
  "cannot mutate decision result",
  "cannot affect routing",
  "cannot affect invariant evaluation",
  "cannot alter explanation",
  "cannot alter audit artifacts",
  "cannot alter stage history",
  "cannot alter digest source semantics",
  "cannot alter packet ordering determinism",
] as const);

export function getGovernanceOperatorPacketLayerGuarantees(): readonly string[] {
  return GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES;
}
