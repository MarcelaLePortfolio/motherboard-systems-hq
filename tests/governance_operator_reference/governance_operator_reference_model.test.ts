import { describe, expect, it } from "vitest";
import type { GovernanceOperatorReferenceRecord } from "../../src/governance_operator_reference/governance_operator_reference_model";

describe("governance_operator_reference_model", () => {
  it("supports deterministic reference structure", () => {
    const record: GovernanceOperatorReferenceRecord = {
      headline: "Governance operator reference: dec-3000 (WARN)",
      metadata: {
        decision_id: "dec-3000",
        reference_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000003000,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-3000");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
