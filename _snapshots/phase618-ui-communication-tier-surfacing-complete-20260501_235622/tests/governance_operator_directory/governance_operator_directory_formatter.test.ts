import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorDirectoryCompleteness,
  formatGovernanceOperatorDirectoryDecision,
  formatGovernanceOperatorDirectoryHeadline,
  formatGovernanceOperatorDirectoryReadiness,
  formatGovernanceOperatorDirectorySections,
  formatGovernanceOperatorDirectoryVersion,
} from "../../src/governance_operator_directory/governance_operator_directory_formatter";

describe("governance_operator_directory_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorDirectoryHeadline("dec-2400", "BLOCK")).toBe(
      "Governance operator directory: dec-2400 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorDirectoryDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorDirectorySections(["Overview", "Registry", "Directory"]),
    ).toBe("Sections: Overview, Registry, Directory");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorDirectorySections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorDirectoryReadiness(true)).toBe("Directory ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorDirectoryCompleteness(true)).toBe(
      "Directory complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorDirectoryVersion("1")).toBe("Directory version: 1");
  });
});
