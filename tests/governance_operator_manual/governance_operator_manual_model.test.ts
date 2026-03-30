import { describe, expect, it } from "vitest";
import type { GovernanceOperatorManualRecord } from "../../src/governance_operator_manual/governance_operator_manual_model";

describe("governance_operator_manual_model", () => {
  it("supports deterministic manual structure", () => {
    const record: GovernanceOperatorManualRecord = {
      headline: "Governance operator manual: dec-2600 (WARN)",
      metadata: {
        decision_id: "dec-2600",
        manual_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002600,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2600");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
