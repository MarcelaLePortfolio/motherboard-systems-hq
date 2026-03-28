import { describe, expect, it } from "vitest";
import type { GovernanceDigestRecord } from "../../src/governance_digest/governance_digest_model";

describe("governance_digest_model", () => {
  it("supports deterministic digest structure", () => {
    const record: GovernanceDigestRecord = {
      decision_id: "dec-300",
      headline: "Governance digest: dec-300 (WARN)",
      lines: [{ key: "decision", text: "Decision: WARN" }],
      timestamp: 1710000000300,
    };

    expect(record.decision_id).toBe("dec-300");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
