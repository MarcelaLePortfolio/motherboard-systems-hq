import {
  groupSignalsBySeverity,
  buildGovernancePresentation
} from "./governance_advisory_presenter";

import type { GovernanceAdvisorySignal } from "./governance_advisory_contract";

function buildSignal(
  id: string,
  severity: GovernanceAdvisorySignal["severity"]
): GovernanceAdvisorySignal {

  return {
    id,
    domain: "governance_integrity",
    severity,
    summary: "test",
    detail: "detail",
    operator_guidance: "none",
    reasoning: "test",
    detected_at: "2026-03-27T00:00:00.000Z",
    source: "test",
    verified: true
  };

}

describe("governance presentation layer", () => {

  it("groups signals by severity", () => {

    const signals = [

      buildSignal("1","warning"),
      buildSignal("2","critical"),
      buildSignal("3","warning")

    ];

    const groups = groupSignalsBySeverity(signals);

    expect(groups.length).toBe(2);

    expect(groups[0].severity).toBe("critical");

    expect(groups[1].severity).toBe("warning");

    expect(groups[1].count).toBe(2);

  });

  it("builds presentation report", () => {

    const signals = [

      buildSignal("1","info"),
      buildSignal("2","risk")

    ];

    const report = buildGovernancePresentation(signals);

    expect(report.total_signals).toBe(2);

    expect(report.groups.length).toBe(2);

  });

});
