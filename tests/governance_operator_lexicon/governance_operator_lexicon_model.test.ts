import { describe, expect, it } from "vitest";
import type { GovernanceOperatorLexiconRecord } from "../../src/governance_operator_lexicon/governance_operator_lexicon_model";

describe("governance_operator_lexicon_model", () => {
  it("supports deterministic lexicon structure", () => {
    const record: GovernanceOperatorLexiconRecord = {
      headline: "Governance operator lexicon",
      metadata: {
        lexicon_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000005000,
      },
      lines: [{ key: "terms", text: "Terms: governance" }],
    };

    expect(record.metadata.lexicon_version).toBe("1");
    expect(record.lines[0]?.key).toBe("terms");
    expect(record.lines[0]?.text).toBe("Terms: governance");
  });
});
