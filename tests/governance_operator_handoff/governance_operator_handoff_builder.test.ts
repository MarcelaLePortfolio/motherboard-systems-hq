import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorHandoff } from "../../src/governance_operator_handoff/governance_operator_handoff_builder";

describe("governance_operator_handoff_builder", () => {
  it("builds a deterministic governance operator handoff", () => {
    const result = buildGovernanceOperatorHandoff({
      decision_id: "dec-801",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000000801,
    });

    expect(result).toEqual({
      headline: "Governance operator handoff: dec-801 (WARN)",
      metadata: {
        decision_id: "dec-801",
        handoff_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000801,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Handoff ready: yes" },
        { key: "complete", text: "Handoff complete: yes" },
        { key: "version", text: "Handoff version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorHandoff({
      decision_id: "dec-802",
      decision: "ALLOW",
      timestamp: 1710000000802,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Handoff ready: yes");
    expect(result.lines[3]?.text).toBe("Handoff complete: yes");
    expect(result.lines[4]?.text).toBe("Handoff version: 1");
  });
});
