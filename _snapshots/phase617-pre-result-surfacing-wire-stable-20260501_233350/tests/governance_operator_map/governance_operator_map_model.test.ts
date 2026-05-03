import { describe, expect, it } from "vitest";
import type { GovernanceOperatorMapRecord } from "../../src/governance_operator_map/governance_operator_map_model";

describe("governance_operator_map_model", () => {
  it("supports deterministic map structure", () => {
    const record: GovernanceOperatorMapRecord = {
      headline: "Governance operator map: dec-2000 (WARN)",
      metadata: {
        decision_id: "dec-2000",
        map_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002000,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2000");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
