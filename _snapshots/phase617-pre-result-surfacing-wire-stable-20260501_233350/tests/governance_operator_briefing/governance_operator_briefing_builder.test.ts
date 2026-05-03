import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorBriefing } from "../../src/governance_operator_briefing/governance_operator_briefing_builder";

describe("governance_operator_briefing_builder", () => {
  it("builds a deterministic governance operator briefing", () => {
    const result = buildGovernanceOperatorBriefing({
      decision_id: "dec-601",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000000601,
    });

    expect(result).toEqual({
      headline: "Governance operator briefing: dec-601 (WARN)",
      metadata: {
        decision_id: "dec-601",
        briefing_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000601,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Briefing ready: yes" },
        { key: "complete", text: "Briefing complete: yes" },
        { key: "version", text: "Briefing version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorBriefing({
      decision_id: "dec-602",
      decision: "ALLOW",
      timestamp: 1710000000602,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Briefing ready: yes");
    expect(result.lines[3]?.text).toBe("Briefing complete: yes");
    expect(result.lines[4]?.text).toBe("Briefing version: 1");
  });
});
