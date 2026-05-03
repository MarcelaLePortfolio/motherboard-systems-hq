import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorLexicon } from "../../src/governance_operator_lexicon/governance_operator_lexicon_builder";

describe("governance_operator_lexicon_builder", () => {
  it("builds deterministic lexicon", () => {
    const result = buildGovernanceOperatorLexicon({
      terms: ["governance", "operator"],
      timestamp: 1710000005001,
    });

    expect(result.metadata.lexicon_version).toBe("1");
    expect(result.lines[0]?.text).toBe("Terms: governance, operator");
    expect(result.lines[1]?.text).toBe("Lexicon ready: yes");
    expect(result.lines[2]?.text).toBe("Lexicon complete: yes");
    expect(result.lines[3]?.text).toBe("Lexicon version: 1");
  });

  it("normalizes optional fields", () => {
    const result = buildGovernanceOperatorLexicon({
      timestamp: 1710000005002,
    });

    expect(result.lines[0]?.text).toBe("Terms: none");
  });
});
