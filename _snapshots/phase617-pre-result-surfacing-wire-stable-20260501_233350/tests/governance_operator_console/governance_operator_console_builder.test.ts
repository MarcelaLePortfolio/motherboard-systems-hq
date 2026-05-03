import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorConsole } from "../../src/governance_operator_console/governance_operator_console_builder";

describe("governance_operator_console_builder", () => {
  it("builds a deterministic governance operator console", () => {
    const result = buildGovernanceOperatorConsole({
      decision_id: "dec-701",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000000701,
    });

    expect(result).toEqual({
      headline: "Governance operator console: dec-701 (WARN)",
      metadata: {
        decision_id: "dec-701",
        console_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000701,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Console ready: yes" },
        { key: "complete", text: "Console complete: yes" },
        { key: "version", text: "Console version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorConsole({
      decision_id: "dec-702",
      decision: "ALLOW",
      timestamp: 1710000000702,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Console ready: yes");
    expect(result.lines[3]?.text).toBe("Console complete: yes");
    expect(result.lines[4]?.text).toBe("Console version: 1");
  });
});
