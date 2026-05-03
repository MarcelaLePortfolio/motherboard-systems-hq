import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_VISIBILITY_LAYER_GUARANTEES,
  getGovernanceVisibilityLayerGuarantees,
} from "../../src/governance_visibility/governance_visibility_contract";

describe("governance_visibility_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_VISIBILITY_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision",
      "cannot affect routing",
      "cannot affect policy result",
      "cannot change explanation",
      "cannot change audit log",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceVisibilityLayerGuarantees()).toBe(
      GOVERNANCE_VISIBILITY_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_VISIBILITY_LAYER_GUARANTEES)).toBe(true);
  });
});
