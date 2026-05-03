import { describe, expect, it } from "vitest";
import {
  GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES,
  getGovernanceOperatorGlossaryLayerGuarantees,
} from "../../src/governance_operator_glossary/governance_operator_glossary_contract";

describe("governance_operator_glossary_contract", () => {
  it("exposes guarantees", () => {
    expect(GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES.length)
      .toBeGreaterThan(0);
  });

  it("returns frozen list", () => {
    expect(Object.isFrozen(GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES))
      .toBe(true);

    expect(getGovernanceOperatorGlossaryLayerGuarantees())
      .toBe(GOVERNANCE_OPERATOR_GLOSSARY_LAYER_GUARANTEES);
  });
});
