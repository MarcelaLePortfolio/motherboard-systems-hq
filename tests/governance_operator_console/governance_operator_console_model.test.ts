import { describe, expect, it } from "vitest";
import type { GovernanceOperatorConsoleRecord } from "../../src/governance_operator_console/governance_operator_console_model";

describe("governance_operator_console_model", () => {
  it("supports deterministic console structure", () => {
    const record: GovernanceOperatorConsoleRecord = {
      headline: "Governance operator console: dec-700 (WARN)",
      metadata: {
        decision_id: "dec-700",
        console_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000700,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-700");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
