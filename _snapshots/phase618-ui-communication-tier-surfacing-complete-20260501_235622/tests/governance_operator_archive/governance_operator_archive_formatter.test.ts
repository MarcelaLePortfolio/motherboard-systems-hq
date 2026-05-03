import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorArchiveCompleteness,
  formatGovernanceOperatorArchiveDecision,
  formatGovernanceOperatorArchiveHeadline,
  formatGovernanceOperatorArchiveReadiness,
  formatGovernanceOperatorArchiveSections,
  formatGovernanceOperatorArchiveVersion,
} from "../../src/governance_operator_archive/governance_operator_archive_formatter";

describe("governance_operator_archive_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorArchiveHeadline("dec-1300", "BLOCK")).toBe(
      "Governance operator archive: dec-1300 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorArchiveDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorArchiveSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorArchiveSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorArchiveReadiness(true)).toBe("Archive ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorArchiveCompleteness(true)).toBe(
      "Archive complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorArchiveVersion("1")).toBe("Archive version: 1");
  });
});
