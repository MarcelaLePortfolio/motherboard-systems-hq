import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorCatalog } from "../../src/governance_operator_catalog/governance_operator_catalog_builder";

describe("governance_operator_catalog_builder", () => {
  it("builds a deterministic governance operator catalog", () => {
    const result = buildGovernanceOperatorCatalog({
      decision_id: "dec-1701",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001701,
    });

    expect(result).toEqual({
      headline: "Governance operator catalog: dec-1701 (WARN)",
      metadata: {
        decision_id: "dec-1701",
        catalog_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001701,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Catalog ready: yes" },
        { key: "complete", text: "Catalog complete: yes" },
        { key: "version", text: "Catalog version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorCatalog({
      decision_id: "dec-1702",
      decision: "ALLOW",
      timestamp: 1710000001702,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Catalog ready: yes");
    expect(result.lines[3]?.text).toBe("Catalog complete: yes");
    expect(result.lines[4]?.text).toBe("Catalog version: 1");
  });
});
