import { describe, expect, it } from "vitest";
import type { GovernanceOperatorSnapshotRecord } from "../../src/governance_operator_snapshot/governance_operator_snapshot_model";

describe("governance_operator_snapshot_model", () => {
  it("supports deterministic snapshot structure", () => {
    const record: GovernanceOperatorSnapshotRecord = {
      headline: "Governance operator snapshot: dec-1000 (WARN)",
      metadata: {
        decision_id: "dec-1000",
        snapshot_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001000,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1000");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
