import { describe, expect, it } from "vitest";
import type { GovernanceOperatorExportRecord } from "../../src/governance_operator_export/governance_operator_export_model";

describe("governance_operator_export_model", () => {
  it("supports deterministic export structure", () => {
    const record: GovernanceOperatorExportRecord = {
      headline: "Governance operator export: dec-1200 (WARN)",
      metadata: {
        decision_id: "dec-1200",
        export_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001200,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1200");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
