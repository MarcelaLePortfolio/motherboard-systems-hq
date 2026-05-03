import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES,
  getGovernanceOperatorMapLayerGuarantees,
} from "../../src/governance_operator_map/governance_operator_map_contract";

describe("governance_operator_map_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter manifest index source semantics",
      "cannot alter map ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorMapLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_MAP_LAYER_GUARANTEES)).toBe(true);
  });
});
