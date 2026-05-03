import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES,
  getGovernanceOperatorHandbookLayerGuarantees,
} from "../../src/governance_operator_handbook/governance_operator_handbook_contract";

describe("governance_operator_handbook_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter playbook source semantics",
      "cannot alter handbook ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorHandbookLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_HANDBOOK_LAYER_GUARANTEES)).toBe(true);
  });
});
