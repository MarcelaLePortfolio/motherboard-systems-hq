import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorManual } from "../../src/governance_operator_manual/governance_operator_manual_builder";

describe("governance_operator_manual_builder", () => {
  it("builds a deterministic governance operator manual", () => {
    const result = buildGovernanceOperatorManual({
      decision_id: "dec-2601",
      decision: "WARN",
      section_titles: ["Overview", "Guide", "Manual"],
      timestamp: 1710000002601,
    });

    expect(result).toEqual({
      headline: "Governance operator manual: dec-2601 (WARN)",
      metadata: {
        decision_id: "dec-2601",
        manual_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002601,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Guide, Manual" },
        { key: "ready", text: "Manual ready: yes" },
        { key: "complete", text: "Manual complete: yes" },
        { key: "version", text: "Manual version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorManual({
      decision_id: "dec-2602",
      decision: "ALLOW",
      timestamp: 1710000002602,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Manual ready: yes");
    expect(result.lines[3]?.text).toBe("Manual complete: yes");
    expect(result.lines[4]?.text).toBe("Manual version: 1");
  });
});
