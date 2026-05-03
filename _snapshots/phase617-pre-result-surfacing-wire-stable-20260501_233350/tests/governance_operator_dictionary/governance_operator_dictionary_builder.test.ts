import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorDictionary } from "../../src/governance_operator_dictionary/governance_operator_dictionary_builder";

describe("governance_operator_dictionary_builder", () => {
  it("builds deterministic dictionary", () => {
    const result = buildGovernanceOperatorDictionary({
      terms: ["governance", "operator"],
      timestamp: 1710000006001,
    });

    expect(result.metadata.dictionary_version).toBe("1");
    expect(result.lines[0]?.text).toBe("Terms: governance, operator");
    expect(result.lines[1]?.text).toBe("Dictionary ready: yes");
    expect(result.lines[2]?.text).toBe("Dictionary complete: yes");
    expect(result.lines[3]?.text).toBe("Dictionary version: 1");
  });

  it("normalizes optional fields", () => {
    const result = buildGovernanceOperatorDictionary({
      timestamp: 1710000006002,
    });

    expect(result.lines[0]?.text).toBe("Terms: none");
  });
});
