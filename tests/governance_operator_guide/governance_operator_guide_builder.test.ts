import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorGuide } from "../../src/governance_operator_guide/governance_operator_guide_builder";

describe("governance_operator_guide_builder", () => {
  it("builds a deterministic governance operator guide", () => {
    const result = buildGovernanceOperatorGuide({
      decision_id: "dec-2501",
      decision: "WARN",
      section_titles: ["Overview", "Directory", "Guide"],
      timestamp: 1710000002501,
    });

    expect(result).toEqual({
      headline: "Governance operator guide: dec-2501 (WARN)",
      metadata: {
        decision_id: "dec-2501",
        guide_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002501,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Directory, Guide" },
        { key: "ready", text: "Guide ready: yes" },
        { key: "complete", text: "Guide complete: yes" },
        { key: "version", text: "Guide version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorGuide({
      decision_id: "dec-2502",
      decision: "ALLOW",
      timestamp: 1710000002502,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Guide ready: yes");
    expect(result.lines[3]?.text).toBe("Guide complete: yes");
    expect(result.lines[4]?.text).toBe("Guide version: 1");
  });
});
