import { describe, expect, it } from "vitest";
import type { GovernanceOperatorGuideRecord } from "../../src/governance_operator_guide/governance_operator_guide_model";

describe("governance_operator_guide_model", () => {
  it("supports deterministic guide structure", () => {
    const record: GovernanceOperatorGuideRecord = {
      headline: "Governance operator guide: dec-2500 (WARN)",
      metadata: {
        decision_id: "dec-2500",
        guide_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002500,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2500");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
