import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES,
  getGovernanceOperatorCompendiumLayerGuarantees,
} from "../../src/governance_operator_compendium/governance_operator_compendium_contract";

describe("governance_operator_compendium_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter handbook source semantics",
      "cannot alter compendium ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorCompendiumLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_COMPENDIUM_LAYER_GUARANTEES)).toBe(true);
  });
});
