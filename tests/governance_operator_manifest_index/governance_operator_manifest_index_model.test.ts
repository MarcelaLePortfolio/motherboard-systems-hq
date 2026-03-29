import { describe, expect, it } from "vitest";
import type { GovernanceOperatorManifestIndexRecord } from "../../src/governance_operator_manifest_index/governance_operator_manifest_index_model";

describe("governance_operator_manifest_index_model", () => {
  it("supports deterministic manifest index structure", () => {
    const record: GovernanceOperatorManifestIndexRecord = {
      headline: "Governance operator manifest index: dec-1900 (WARN)",
      metadata: {
        decision_id: "dec-1900",
        manifest_index_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001900,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1900");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
