import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorPlaybook } from "../../src/governance_operator_playbook/governance_operator_playbook_builder";

describe("governance_operator_playbook_builder", () => {
  it("builds a deterministic governance operator playbook", () => {
    const result = buildGovernanceOperatorPlaybook({
      decision_id: "dec-2701",
      decision: "WARN",
      section_titles: ["Overview", "Manual", "Playbook"],
      timestamp: 1710000002701,
    });

    expect(result).toEqual({
      headline: "Governance operator playbook: dec-2701 (WARN)",
      metadata: {
        decision_id: "dec-2701",
        playbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002701,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Manual, Playbook" },
        { key: "ready", text: "Playbook ready: yes" },
        { key: "complete", text: "Playbook complete: yes" },
        { key: "version", text: "Playbook version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorPlaybook({
      decision_id: "dec-2702",
      decision: "ALLOW",
      timestamp: 1710000002702,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Playbook ready: yes");
    expect(result.lines[3]?.text).toBe("Playbook complete: yes");
    expect(result.lines[4]?.text).toBe("Playbook version: 1");
  });
});
