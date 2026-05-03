import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES,
  getGovernanceOperatorCatalogLayerGuarantees,
} from "../../src/governance_operator_catalog/governance_operator_catalog_contract";

describe("governance_operator_catalog_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter register source semantics",
      "cannot alter catalog ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorCatalogLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_CATALOG_LAYER_GUARANTEES)).toBe(true);
  });
});
