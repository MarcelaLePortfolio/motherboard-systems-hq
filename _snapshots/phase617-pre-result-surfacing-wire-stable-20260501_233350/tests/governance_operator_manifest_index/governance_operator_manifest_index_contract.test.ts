import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES,
  getGovernanceOperatorManifestIndexLayerGuarantees,
} from "../../src/governance_operator_manifest_index/governance_operator_manifest_index_contract";

describe("governance_operator_manifest_index_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter index source semantics",
      "cannot alter manifest index ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorManifestIndexLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_MANIFEST_INDEX_LAYER_GUARANTEES)).toBe(true);
  });
});
