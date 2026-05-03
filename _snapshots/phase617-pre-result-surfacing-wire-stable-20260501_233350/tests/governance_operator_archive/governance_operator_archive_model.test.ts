import { describe, expect, it } from "vitest";
import type { GovernanceOperatorArchiveRecord } from "../../src/governance_operator_archive/governance_operator_archive_model";

describe("governance_operator_archive_model", () => {
  it("supports deterministic archive structure", () => {
    const record: GovernanceOperatorArchiveRecord = {
      headline: "Governance operator archive: dec-1300 (WARN)",
      metadata: {
        decision_id: "dec-1300",
        archive_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001300,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1300");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
