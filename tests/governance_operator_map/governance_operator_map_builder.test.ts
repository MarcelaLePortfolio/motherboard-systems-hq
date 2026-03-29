import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorMap } from "../../src/governance_operator_map/governance_operator_map_builder";

describe("governance_operator_map_builder", () => {
  it("builds a deterministic governance operator map", () => {
    const result = buildGovernanceOperatorMap({
      decision_id: "dec-2001",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000002001,
    });

    expect(result).toEqual({
      headline: "Governance operator map: dec-2001 (WARN)",
      metadata: {
        decision_id: "dec-2001",
        map_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002001,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Map ready: yes" },
        { key: "complete", text: "Map complete: yes" },
        { key: "version", text: "Map version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorMap({
      decision_id: "dec-2002",
      decision: "ALLOW",
      timestamp: 1710000002002,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Map ready: yes");
    expect(result.lines[3]?.text).toBe("Map complete: yes");
    expect(result.lines[4]?.text).toBe("Map version: 1");
  });
});
