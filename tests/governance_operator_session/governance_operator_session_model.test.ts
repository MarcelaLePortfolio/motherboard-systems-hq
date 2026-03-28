import { describe, expect, it } from "vitest";
import type { GovernanceOperatorSessionRecord } from "../../src/governance_operator_session/governance_operator_session_model";

describe("governance_operator_session_model", () => {
  it("supports deterministic session structure", () => {
    const record: GovernanceOperatorSessionRecord = {
      headline: "Governance operator session: dec-900 (WARN)",
      metadata: {
        decision_id: "dec-900",
        session_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000900,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-900");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
