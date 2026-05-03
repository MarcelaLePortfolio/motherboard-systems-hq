import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorSnapshotCompleteness,
  formatGovernanceOperatorSnapshotDecision,
  formatGovernanceOperatorSnapshotHeadline,
  formatGovernanceOperatorSnapshotReadiness,
  formatGovernanceOperatorSnapshotSections,
  formatGovernanceOperatorSnapshotVersion,
} from "../../src/governance_operator_snapshot/governance_operator_snapshot_formatter";

describe("governance_operator_snapshot_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorSnapshotHeadline("dec-1000", "BLOCK")).toBe(
      "Governance operator snapshot: dec-1000 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorSnapshotDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorSnapshotSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorSnapshotSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorSnapshotReadiness(true)).toBe("Snapshot ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorSnapshotCompleteness(true)).toBe(
      "Snapshot complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorSnapshotVersion("1")).toBe("Snapshot version: 1");
  });
});
