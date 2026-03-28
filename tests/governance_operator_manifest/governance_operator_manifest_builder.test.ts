import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorManifest } from "../../src/governance_operator_manifest/governance_operator_manifest_builder";

describe("governance_operator_manifest_builder", () => {
  it("builds a deterministic governance operator manifest", () => {
    const result = buildGovernanceOperatorManifest({
      decision_id: "dec-501",
      decision: "WARN",
      section_titles: ["Overview", "Evaluation", "Artifacts"],
      timestamp: 1710000000501,
    });

    expect(result).toEqual({
      headline: "Governance operator manifest: dec-501 (WARN)",
      metadata: {
        decision_id: "dec-501",
        manifest_version: "1",
        ready: true,
        complete: true,
        timestamp: 1710000000501,
      },
      entries: [
        { key: "decision", text: "Decision: WARN" },
        { key: "sections", text: "Sections: Overview, Evaluation, Artifacts" },
        { key: "ready", text: "Manifest ready: yes" },
        { key: "complete", text: "Manifest complete: yes" },
        { key: "version", text: "Manifest version: 1" },
      ],
    });
  });

  it("normalizes optional fields safely", () => {
    const result = buildGovernanceOperatorManifest({
      decision_id: "dec-502",
      decision: "ALLOW",
      timestamp: 1710000000502,
    });

    expect(result.entries[1]?.text).toBe("Sections: none");
    expect(result.entries[2]?.text).toBe("Manifest ready: yes");
    expect(result.entries[3]?.text).toBe("Manifest complete: yes");
    expect(result.entries[4]?.text).toBe("Manifest version: 1");
  });
});
