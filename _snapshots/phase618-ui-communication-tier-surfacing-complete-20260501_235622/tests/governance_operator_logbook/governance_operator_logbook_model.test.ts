import { describe, expect, it } from "vitest";
import type { GovernanceOperatorLogbookRecord } from "../../src/governance_operator_logbook/governance_operator_logbook_model";

describe("governance_operator_logbook_model", () => {
  it("supports deterministic logbook structure", () => {
    const record: GovernanceOperatorLogbookRecord = {
      headline: "Governance operator logbook: dec-1500 (WARN)",
      metadata: {
        decision_id: "dec-1500",
        logbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001500,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1500");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
