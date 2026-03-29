import { describe, expect, it } from "vitest";
import {
  formatGovernanceOperatorCatalogCompleteness,
  formatGovernanceOperatorCatalogDecision,
  formatGovernanceOperatorCatalogHeadline,
  formatGovernanceOperatorCatalogReadiness,
  formatGovernanceOperatorCatalogSections,
  formatGovernanceOperatorCatalogVersion,
} from "../../src/governance_operator_catalog/governance_operator_catalog_formatter";

describe("governance_operator_catalog_formatter", () => {
  it("formats headline", () => {
    expect(formatGovernanceOperatorCatalogHeadline("dec-1700", "BLOCK")).toBe(
      "Governance operator catalog: dec-1700 (BLOCK)",
    );
  });

  it("formats decision", () => {
    expect(formatGovernanceOperatorCatalogDecision("WARN")).toBe("Decision: WARN");
  });

  it("formats sections", () => {
    expect(
      formatGovernanceOperatorCatalogSections(["Overview", "Evaluation", "Artifacts"]),
    ).toBe("Sections: Overview, Evaluation, Artifacts");
  });

  it("formats empty sections", () => {
    expect(formatGovernanceOperatorCatalogSections([])).toBe("Sections: none");
  });

  it("formats readiness", () => {
    expect(formatGovernanceOperatorCatalogReadiness(true)).toBe("Catalog ready: yes");
  });

  it("formats completeness", () => {
    expect(formatGovernanceOperatorCatalogCompleteness(true)).toBe(
      "Catalog complete: yes",
    );
  });

  it("formats version", () => {
    expect(formatGovernanceOperatorCatalogVersion("1")).toBe("Catalog version: 1");
  });
});
