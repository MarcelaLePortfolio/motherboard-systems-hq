import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES,
  getGovernanceOperatorManualLayerGuarantees,
} from "../../src/governance_operator_manual/governance_operator_manual_contract";

describe("governance_operator_manual_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter guide source semantics",
      "cannot alter manual ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorManualLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_MANUAL_LAYER_GUARANTEES)).toBe(true);
  });
});
