import { describe, expect, it } from "vitest";
import type { GovernanceOperatorPlaybookRecord } from "../../src/governance_operator_playbook/governance_operator_playbook_model";

describe("governance_operator_playbook_model", () => {
  it("supports deterministic playbook structure", () => {
    const record: GovernanceOperatorPlaybookRecord = {
      headline: "Governance operator playbook: dec-2700 (WARN)",
      metadata: {
        decision_id: "dec-2700",
        playbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002700,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2700");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
