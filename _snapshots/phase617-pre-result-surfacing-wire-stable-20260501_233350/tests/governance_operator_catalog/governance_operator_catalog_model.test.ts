import { describe, expect, it } from "vitest";
import type { GovernanceOperatorCatalogRecord } from "../../src/governance_operator_catalog/governance_operator_catalog_model";

describe("governance_operator_catalog_model", () => {
  it("supports deterministic catalog structure", () => {
    const record: GovernanceOperatorCatalogRecord = {
      headline: "Governance operator catalog: dec-1700 (WARN)",
      metadata: {
        decision_id: "dec-1700",
        catalog_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001700,
      },
      lines: [{ key: "decision", text: "Decision: WARN" }],
    };

    expect(record.metadata.decision_id).toBe("dec-1700");
    expect(record.lines[0]?.key).toBe("decision");
    expect(record.lines[0]?.text).toBe("Decision: WARN");
  });
});
