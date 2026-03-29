import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorIndex } from "../../src/governance_operator_index/governance_operator_index_builder";

describe("governance_operator_index_builder", () => {
  it("builds a deterministic governance operator index", () => {
    const result = buildGovernanceOperatorIndex({
      decision_id: "dec-1801",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001801,
    });

    expect(result).toEqual({
      headline: "Governance operator index: dec-1801 (WARN)",
      metadata: {
        decision_id: "dec-1801",
        index_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001801,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Index ready: yes" },
        { key: "complete", text: "Index complete: yes" },
        { key: "version", text: "Index version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorIndex({
      decision_id: "dec-1802",
      decision: "ALLOW",
      timestamp: 1710000001802,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Index ready: yes");
    expect(result.lines[3]?.text).toBe("Index complete: yes");
    expect(result.lines[4]?.text).toBe("Index version: 1");
  });
});
