import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorLogbook } from "../../src/governance_operator_logbook/governance_operator_logbook_builder";

describe("governance_operator_logbook_builder", () => {
  it("builds a deterministic governance operator logbook", () => {
    const result = buildGovernanceOperatorLogbook({
      decision_id: "dec-1501",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001501,
    });

    expect(result).toEqual({
      headline: "Governance operator logbook: dec-1501 (WARN)",
      metadata: {
        decision_id: "dec-1501",
        logbook_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001501,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Logbook ready: yes" },
        { key: "complete", text: "Logbook complete: yes" },
        { key: "version", text: "Logbook version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorLogbook({
      decision_id: "dec-1502",
      decision: "ALLOW",
      timestamp: 1710000001502,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Logbook ready: yes");
    expect(result.lines[3]?.text).toBe("Logbook complete: yes");
    expect(result.lines[4]?.text).toBe("Logbook version: 1");
  });
});
