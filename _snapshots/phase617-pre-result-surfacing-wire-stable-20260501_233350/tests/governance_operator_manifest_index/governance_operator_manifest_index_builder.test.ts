import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorManifestIndex } from "../../src/governance_operator_manifest_index/governance_operator_manifest_index_builder";

describe("governance_operator_manifest_index_builder", () => {
  it("builds a deterministic governance operator manifest index", () => {
    const result = buildGovernanceOperatorManifestIndex({
      decision_id: "dec-1901",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000001901,
    });

    expect(result).toEqual({
      headline: "Governance operator manifest index: dec-1901 (WARN)",
      metadata: {
        decision_id: "dec-1901",
        manifest_index_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000001901,
      },
      lines: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Manifest index ready: yes" },
        { key: "complete", text: "Manifest index complete: yes" },
        { key: "version", text: "Manifest index version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorManifestIndex({
      decision_id: "dec-1902",
      decision: "ALLOW",
      timestamp: 1710000001902,
    });

    expect(result.lines[1]?.text).toBe("Sections: none");
    expect(result.lines[2]?.text).toBe("Manifest index ready: yes");
    expect(result.lines[3]?.text).toBe("Manifest index complete: yes");
    expect(result.lines[4]?.text).toBe("Manifest index version: 1");
  });
});
