import { describe, expect, it } from "vitest";
import type { GovernanceReportRecord } from "../../src/governance_reporting/governance_reporting_model";

describe("governance_reporting_model", () => {
  it("supports deterministic report structure", () => {
    const record: GovernanceReportRecord = {
      decision_id: "dec-200",
      headline: "Governance report: dec-200 (WARN)",
      sections: [
        {
          title: "Decision Summary",
          lines: [{ label: "decision", value: "Decision: WARN" }],
        },
      ],
      timestamp: 1710000000200,
    };

    expect(record.decision_id).toBe("dec-200");
    expect(record.sections[0]?.title).toBe("Decision Summary");
    expect(record.sections[0]?.lines[0]?.value).toBe("Decision: WARN");
  });
});
