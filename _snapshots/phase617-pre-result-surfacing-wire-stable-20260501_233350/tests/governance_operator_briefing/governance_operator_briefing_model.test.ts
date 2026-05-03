import { describe, expect, it } from "vitest";
import type { GovernanceOperatorBriefingRecord } from "../../src/governance_operator_briefing/governance_operator_briefing_model";

describe("governance_operator_briefing_model", () => {
  it("supports deterministic briefing structure", () => {
    const record: GovernanceOperatorBriefingRecord = {
      headline: "Governance operator briefing: dec-600 (WARN)",
      metadata: {
        decision_id: "dec-600",
        briefing_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000600,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-600");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
