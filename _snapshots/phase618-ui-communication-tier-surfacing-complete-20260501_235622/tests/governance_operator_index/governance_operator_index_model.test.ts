import { describe, expect, it } from "vitest";
import type { GovernanceOperatorIndexRecord } from "../../src/governance_operator_index/governance_operator_index_model";

describe("governance_operator_index_model", () => {
  it("supports deterministic index structure", () => {
    const record: GovernanceOperatorIndexRecord = {
      headline: "Governance operator index: dec-1800 (WARN)",
      metadata: {
        decision_id: "dec-1800",
        index_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001800,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1800");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
