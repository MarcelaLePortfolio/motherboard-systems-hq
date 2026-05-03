import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorArchive } from "../../src/governance_operator_archive/governance_operator_archive_builder";

describe("governance_operator_archive_builder", () => {
  it("builds a deterministic governance operator archive", () => {
    const result = buildGovernanceOperatorArchive({
      decision_id: "dec-1301",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001301,
    });

    expect(result).toEqual({
      headline: "Governance operator archive: dec-1301 (WARN)",
      metadata: {
        decision_id: "dec-1301",
        archive_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001301,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Archive ready: yes" },
        { key: "complete", text: "Archive complete: yes" },
        { key: "version", text: "Archive version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorArchive({
      decision_id: "dec-1302",
      decision: "ALLOW",
      timestamp: 1710000001302,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Archive ready: yes");
    expect(result.lines[3]?.text).toBe("Archive complete: yes");
    expect(result.lines[4]?.text).toBe("Archive version: 1");
  });
});
