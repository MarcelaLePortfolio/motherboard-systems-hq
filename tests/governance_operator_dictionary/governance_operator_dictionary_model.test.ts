import { describe, expect, it } from "vitest";
import type { GovernanceOperatorDictionaryRecord } from "../../src/governance_operator_dictionary/governance_operator_dictionary_model";

describe("governance_operator_dictionary_model", () => {
  it("supports deterministic dictionary structure", () => {
    const record: GovernanceOperatorDictionaryRecord = {
      headline: "Governance operator dictionary",
      metadata: {
        dictionary_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000006000,
      },
      lines: [{ key: "terms", text: "Terms: governance" }],
    };

    expect(record.metadata.dictionary_version).toBe("1");
    expect(record.lines[0]?.key).toBe("terms");
    expect(record.lines[0]?.text).toBe("Terms: governance");
  });
});
