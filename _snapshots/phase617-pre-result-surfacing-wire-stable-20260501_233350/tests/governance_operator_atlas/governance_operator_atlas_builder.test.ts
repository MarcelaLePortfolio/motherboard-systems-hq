import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorAtlas } from "../../src/governance_operator_atlas/governance_operator_atlas_builder";

describe("governance_operator_atlas_builder", () => {
  it("builds a deterministic governance operator atlas", () => {
    const result = buildGovernanceOperatorAtlas({
      decision_id: "dec-2101",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000002101,
    });

    expect(result).toEqual({
      headline: "Governance operator atlas: dec-2101 (WARN)",
      metadata: {
        decision_id: "dec-2101",
        atlas_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002101,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Atlas ready: yes" },
        { key: "complete", text: "Atlas complete: yes" },
        { key: "version", text: "Atlas version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorAtlas({
      decision_id: "dec-2102",
      decision: "ALLOW",
      timestamp: 1710000002102,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Atlas ready: yes");
    expect(result.lines[3]?.text).toBe("Atlas complete: yes");
    expect(result.lines[4]?.text).toBe("Atlas version: 1");
  });
});
