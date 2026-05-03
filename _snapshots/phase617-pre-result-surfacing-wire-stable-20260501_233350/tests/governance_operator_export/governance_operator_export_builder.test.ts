import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorExport } from "../../src/governance_operator_export/governance_operator_export_builder";

describe("governance_operator_export_builder", () => {
  it("builds a deterministic governance operator export", () => {
    const result = buildGovernanceOperatorExport({
      decision_id: "dec-1201",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001201,
    });

    expect(result).toEqual({
      headline: "Governance operator export: dec-1201 (WARN)",
      metadata: {
        decision_id: "dec-1201",
        export_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001201,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Export ready: yes" },
        { key: "complete", text: "Export complete: yes" },
        { key: "version", text: "Export version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorExport({
      decision_id: "dec-1202",
      decision: "ALLOW",
      timestamp: 1710000001202,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Export ready: yes");
    expect(result.lines[3]?.text).toBe("Export complete: yes");
    expect(result.lines[4]?.text).toBe("Export version: 1");
  });
});
