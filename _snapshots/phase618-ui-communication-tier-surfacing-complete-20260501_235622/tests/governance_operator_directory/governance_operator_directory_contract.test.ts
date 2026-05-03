import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES,
  getGovernanceOperatorDirectoryLayerGuarantees,
} from "../../src/governance_operator_directory/governance_operator_directory_contract";

describe("governance_operator_directory_contract", () => {
  it("exposes deterministic guarantees", () => {
    expect(GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES).toEqual([
      "cannot mutate decision result",
      "cannot affect routing",
      "cannot affect invariant evaluation",
      "cannot alter explanation",
      "cannot alter audit artifacts",
      "cannot alter stage history",
      "cannot alter registry source semantics",
      "cannot alter directory ordering determinism",
    ]);
  });

  it("returns the exact guarantee list", () => {
    expect(getGovernanceOperatorDirectoryLayerGuarantees()).toBe(
      GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES,
    );
  });

  it("prevents mutation of the guarantee list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_DIRECTORY_LAYER_GUARANTEES)).toBe(true);
  });
});
