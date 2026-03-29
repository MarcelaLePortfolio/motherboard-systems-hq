import { describe, expect, it } from "vitest";
import type { GovernanceOperatorRegistryRecord } from "../../src/governance_operator_registry/governance_operator_registry_model";

describe("governance_operator_registry_model", () => {
  it("supports deterministic registry structure", () => {
    const record: GovernanceOperatorRegistryRecord = {
      headline: "Governance operator registry: dec-2300 (WARN)",
      metadata: {
        decision_id: "dec-2300",
        registry_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002300,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2300");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
