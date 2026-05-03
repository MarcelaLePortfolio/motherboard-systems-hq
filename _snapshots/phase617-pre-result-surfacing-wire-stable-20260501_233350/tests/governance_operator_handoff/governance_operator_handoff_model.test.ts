import { describe, expect, it } from "vitest";
import type { GovernanceOperatorHandoffRecord } from "../../src/governance_operator_handoff/governance_operator_handoff_model";

describe("governance_operator_handoff_model", () => {
  it("supports deterministic handoff structure", () => {
    const record: GovernanceOperatorHandoffRecord = {
      headline: "Governance operator handoff: dec-800 (WARN)",
      metadata: {
        decision_id: "dec-800",
        handoff_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000800,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-800");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
