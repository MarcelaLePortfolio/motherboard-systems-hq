import { describe, expect, it } from "vitest";
import type { GovernanceOperatorHandbookRecord } from "../../src/governance_operator_handbook/governance_operator_handbook_model";

describe("governance_operator_handbook_model", () => {
  it("supports deterministic handbook structure", () => {
    const record: GovernanceOperatorHandbookRecord = {
      headline: "Governance operator handbook: dec-2800 (WARN)",
      metadata: {
        decision_id: "dec-2800",
        handbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002800,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2800");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
