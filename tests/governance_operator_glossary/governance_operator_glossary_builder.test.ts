import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorGlossary } from "../../src/governance_operator_glossary/governance_operator_glossary_builder";

describe("governance_operator_glossary_builder", () => {
  it("builds deterministic glossary", () => {
    const result = buildGovernanceOperatorGlossary({
      terms:["governance","operator"],
      timestamp:1710000004001,
    });

    expect(result.metadata.glossary_version).toBe("1");
    expect(result.lines[0].text)
      .toBe("Terms: governance, operator");
  });

  it("normalizes optional fields", () => {
    const result = buildGovernanceOperatorGlossary({
      timestamp:1710000004002,
    });

    expect(result.lines[0].text)
      .toBe("Terms: none");
  });
});
