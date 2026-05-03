import { describe, expect, it } from "vitest";
import type { GovernanceOperatorManifestRecord } from "../../src/governance_operator_manifest/governance_operator_manifest_model";

describe("governance_operator_manifest_model", () => {
  it("supports deterministic manifest structure", () => {
    const record: GovernanceOperatorManifestRecord = {
      headline: "Governance operator manifest: dec-500 (WARN)",
      metadata: {
        decision_id: "dec-500",
        manifest_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000500,
      },
      entries: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-500");
    expect(record.entries[0]?.key).toBe("decision");
    expect(record.entries[0]?.text).toBe("Decision: WARN");
  });
});
