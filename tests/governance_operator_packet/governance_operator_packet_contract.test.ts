import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES,
  getGovernanceOperatorPacketLayerGuarantees,
} from "../../src/governance_operator_packet/governance_operator_packet_contract";

describe("governance_operator_packet_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter digest source semantics",
      "cannot alter packet ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorPacketLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_PACKET_LAYER_GUARANTEES)).toBe(true);
  });
});
