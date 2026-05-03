import { describe, expect, it } from "vitest";
import type { GovernanceOperatorGlossaryRecord } from "../../src/governance_operator_glossary/governance_operator_glossary_model";

describe("governance_operator_glossary_model", () => {
  it("supports deterministic glossary structure", () => {
    const record: GovernanceOperatorGlossaryRecord = {
      headline: "Governance operator glossary",
      metadata: {
        glossary_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000004000,
      },
      lines: [{ key: "terms", text: "Terms: governance" }],
    };

    expect(record.metadata.glossary_version).toBe("1");
    expect(record.lines[0].key).toBe("terms");
  });
});
