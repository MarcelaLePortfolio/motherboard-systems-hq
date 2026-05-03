import { describe, expect, it } from "vitest";
import type { GovernanceOperatorAtlasRecord } from "../../src/governance_operator_atlas/governance_operator_atlas_model";

describe("governance_operator_atlas_model", () => {
  it("supports deterministic atlas structure", () => {
    const record: GovernanceOperatorAtlasRecord = {
      headline: "Governance operator atlas: dec-2100 (WARN)",
      metadata: {
        decision_id: "dec-2100",
        atlas_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002100,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2100");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
