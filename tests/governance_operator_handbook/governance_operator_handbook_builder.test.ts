import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorHandbook } from "../../src/governance_operator_handbook/governance_operator_handbook_builder";

describe("governance_operator_handbook_builder", () => {
  it("builds a deterministic governance operator handbook", () => {
    const result = buildGovernanceOperatorHandbook({
      decision_id: "dec-2801",
      decision: "WARN",
      section_titles: ["Overview", "Playbook", "Handbook"],
      timestamp: 1710000002801,
    });

    expect(result).toEqual({
      headline: "Governance operator handbook: dec-2801 (WARN)",
      metadata: {
        decision_id: "dec-2801",
        handbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002801,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Playbook, Handbook" },
        { key: "ready", text: "Handbook ready: yes" },
        { key: "complete", text: "Handbook complete: yes" },
        { key: "version", text: "Handbook version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorHandbook({
      decision_id: "dec-2802",
      decision: "ALLOW",
      timestamp: 1710000002802,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Handbook ready: yes");
    expect(result.lines[3]?.text).toBe("Handbook complete: yes");
    expect(result.lines[4]?.text).toBe("Handbook version: 1");
  });
});
