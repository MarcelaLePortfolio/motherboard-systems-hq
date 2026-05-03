import { describe, expect, it } from "vitest";
import { buildGovernanceOperatorLedger } from "../../src/governance_operator_ledger/governance_operator_ledger_builder";

describe("governance_operator_ledger_builder", () => {
  it("builds deterministic ledger", () => {
    const result = buildGovernanceOperatorLedger({
      decision_id:"dec-2201",
      decision:"WARN",
      section_titles:["Overview","Audit"],
      timestamp:1710000002201
    });

    expect(result.headline)
      .toBe("Governance operator ledger: dec-2201 (WARN)");

    expect(result.lines[0].text).toBe("Decision: WARN");
    expect(result.lines[1].text).toBe("Sections: Overview, Audit");
    expect(result.lines[2].text).toBe("Ledger ready: yes");
    expect(result.lines[3].text).toBe("Ledger complete: yes");
    expect(result.lines[4].text).toBe("Ledger version: 1");
  });

  it("normalizes optional fields", () => {
    const result = buildGovernanceOperatorLedger({
      decision_id:"dec-2202",
      decision:"ALLOW",
      timestamp:1710000002202
    });

    expect(result.lines[1].text).toBe("Sections: none");
  });
});
