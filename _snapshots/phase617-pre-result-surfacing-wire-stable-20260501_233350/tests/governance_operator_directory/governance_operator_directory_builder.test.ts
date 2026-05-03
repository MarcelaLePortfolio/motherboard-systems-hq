import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorDirectory } from "../../src/governance_operator_directory/governance_operator_directory_builder";

describe("governance_operator_directory_builder", () => {
  it("builds a deterministic governance operator directory", () => {
    const result = buildGovernanceOperatorDirectory({
      decision_id: "dec-2401",
      decision: "WARN",
      section_titles: ["Overview", "Registry", "Directory"],
      timestamp: 1710000002401,
    });

    expect(result).toEqual({
      headline: "Governance operator directory: dec-2401 (WARN)",
      metadata: {
        decision_id: "dec-2401",
        directory_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000002401,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Registry, Directory" },
        { key: "ready", text: "Directory ready: yes" },
        { key: "complete", text: "Directory complete: yes" },
        { key: "version", text: "Directory version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorDirectory({
      decision_id: "dec-2402",
      decision: "ALLOW",
      timestamp: 1710000002402,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Directory ready: yes");
    expect(result.lines[3]?.text).toBe("Directory complete: yes");
    expect(result.lines[4]?.text).toBe("Directory version: 1");
  });
});
