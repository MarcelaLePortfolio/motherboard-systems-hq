import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES,
  getGovernanceOperatorHandoffLayerGuarantees,
} from "../../src/governance_operator_handoff/governance_operator_handoff_contract";

describe("governance_operator_handoff_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter console source semantics",
      "cannot alter handoff ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorHandoffLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_HANDOFF_LAYER_GUARANTEES)).toBe(true);
  });
});
