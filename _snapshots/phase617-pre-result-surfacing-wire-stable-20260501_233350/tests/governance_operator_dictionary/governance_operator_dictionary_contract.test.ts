import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES,
  getGovernanceOperatorDictionaryLayerGuarantees,
} from "../../src/governance_operator_dictionary/governance_operator_dictionary_contract";

describe("governance_operator_dictionary_contract", () => {
  it("exposes guarantees", () => {
    expect(GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES.length)
      .toBeGreaterThan(0);
  });

  it("returns frozen list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES))
      .toBe(true);

    expect(getGovernanceOperatorDictionaryLayerGuarantees())
      .toBe(GOVERNANCE_OPERATOR_DICTIONARY_LAYER_GUARANTEES);
  });
});
