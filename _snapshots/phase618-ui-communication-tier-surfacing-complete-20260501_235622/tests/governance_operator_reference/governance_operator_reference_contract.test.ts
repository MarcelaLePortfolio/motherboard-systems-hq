import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_REFERENCE_LAYER_GUARANTEES,
  getGovernanceOperatorReferenceLayerGuarantees,
} from "../../src/governance_operator_reference/governance_operator_reference_contract";

describe("governance_operator_reference_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_REFERENCE_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter compendium source semantics",
      "cannot alter reference ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorReferenceLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_REFERENCE_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_REFERENCE_LAYER_GUARANTEES)).toBe(true);
  });
});
