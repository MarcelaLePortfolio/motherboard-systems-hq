import { describe, expect, it } from "vitest";
import type { GovernanceOperatorCompendiumRecord } from "../../src/governance_operator_compendium/governance_operator_compendium_model";

describe("governance_operator_compendium_model", () => {
  it("supports deterministic compendium structure", () => {
    const record: GovernanceOperatorCompendiumRecord = {
      headline: "Governance operator compendium: dec-2900 (WARN)",
      metadata: {
        decision_id: "dec-2900",
        compendium_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002900,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-2900");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
