import { describe, expect, it } from "vitest";
import type { GovernanceOperatorRecordRecord } from "../../src/governance_operator_record/governance_operator_record_model";

describe("governance_operator_record_model", () => {
  it("supports deterministic record structure", () => {
    const record: GovernanceOperatorRecordRecord = {
      headline: "Governance operator record: dec-1400 (WARN)",
      metadata: {
        decision_id: "dec-1400",
        record_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001400,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1400");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
