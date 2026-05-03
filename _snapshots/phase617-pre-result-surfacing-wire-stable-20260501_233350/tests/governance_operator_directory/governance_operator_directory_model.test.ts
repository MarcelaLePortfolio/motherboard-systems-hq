import { describe, expect, it } from "vitest";
import type { GovernanceOperatorDirectoryRecord } from "../../src/governance_operator_directory/governance_operator_directory_model";

describe("governance_operator_directory_model", () => {
  it("supports deterministic directory structure", () => {
    const record: GovernanceOperatorDirectoryRecord = {
      headline: "Governance operator directory: dec-2400 (WARN)",
      metadata: {
        decision_id: "dec-2400",
        directory_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002400,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2400");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
