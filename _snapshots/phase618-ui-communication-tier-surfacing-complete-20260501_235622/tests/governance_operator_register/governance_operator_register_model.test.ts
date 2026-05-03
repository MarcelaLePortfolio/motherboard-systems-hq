import { describe, expect, it } from "vitest";
import type { GovernanceOperatorRegisterRecord } from "../../src/governance_operator_register/governance_operator_register_model";

describe("governance_operator_register_model", () => {
  it("supports deterministic register structure", () => {
    const record: GovernanceOperatorRegisterRecord = {
      headline: "Governance operator register: dec-1600 (WARN)",
      metadata: {
        decision_id: "dec-1600",
        register_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001600,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1600");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
