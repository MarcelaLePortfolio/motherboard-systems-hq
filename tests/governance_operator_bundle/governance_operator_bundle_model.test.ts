import { describe, expect, it } from "vitest";
import type { GovernanceOperatorBundleRecord } from "../../src/governance_operator_bundle/governance_operator_bundle_model";

describe("governance_operator_bundle_model", () => {
  it("supports deterministic bundle structure", () => {
    const record: GovernanceOperatorBundleRecord = {
      headline: "Governance operator bundle: dec-1100 (WARN)",
      metadata: {
        decision_id: "dec-1100",
        bundle_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001100,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1100");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
