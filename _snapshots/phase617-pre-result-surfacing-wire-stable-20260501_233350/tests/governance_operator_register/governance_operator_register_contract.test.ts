import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES,
  getGovernanceOperatorRegisterLayerGuarantees,
} from "../../src/governance_operator_register/governance_operator_register_contract";

describe("governance_operator_register_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter logbook source semantics",
      "cannot alter register ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorRegisterLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_REGISTER_LAYER_GUARANTEES)).toBe(true);
  });
});
