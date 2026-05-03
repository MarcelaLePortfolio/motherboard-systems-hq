import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES,
  getGovernanceOperatorAtlasLayerGuarantees,
} from "../../src/governance_operator_atlas/governance_operator_atlas_contract";

describe("governance_operator_atlas_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter map source semantics",
      "cannot alter atlas ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorAtlasLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_ATLAS_LAYER_GUARANTEES)).toBe(true);
  });
});
