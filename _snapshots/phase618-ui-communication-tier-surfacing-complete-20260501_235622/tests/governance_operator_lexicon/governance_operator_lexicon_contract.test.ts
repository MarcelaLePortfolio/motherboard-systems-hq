import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES,
  getGovernanceOperatorLexiconLayerGuarantees,
} from "../../src/governance_operator_lexicon/governance_operator_lexicon_contract";

describe("governance_operator_lexicon_contract", () => {
  it("exposes guarantees", () => {
    expect(GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES.length)
      .toBeGreaterThan(0);
  });

  it("returns frozen list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES))
      .toBe(true);

    expect(getGovernanceOperatorLexiconLayerGuarantees())
      .toBe(GOVERNANCE_OPERATOR_LEXICON_LAYER_GUARANTEES);
  });
});
