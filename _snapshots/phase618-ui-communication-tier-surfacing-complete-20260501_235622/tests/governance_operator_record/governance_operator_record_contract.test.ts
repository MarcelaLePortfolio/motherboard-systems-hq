import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES,
  getGovernanceOperatorRecordLayerGuarantees,
} from "../../src/governance_operator_record/governance_operator_record_contract";

describe("governance_operator_record_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter archive source semantics",
      "cannot alter record ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorRecordLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_RECORD_LAYER_GUARANTEES)).toBe(true);
  });
});
