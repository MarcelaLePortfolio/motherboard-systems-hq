/*
Phase 295 — Governance Advisory Summary Tests
Deterministic cognition validation
*/

import {
  buildGovernanceSummary
} from "./governance_advisory_summary_builder"

import {
  buildGovernancePresentation
} from "./governance_advisory_presenter"

function signal(id:string,severity:string){
  return { id, severity }
}

describe("governance advisory summary", () => {

  it("builds correct severity totals", () => {

    const presentation =
      buildGovernancePresentation([

        signal("1","critical"),
        signal("2","critical"),
        signal("3","risk"),
        signal("4","warning"),
        signal("5","info")

      ])

    const summary =
      buildGovernanceSummary(presentation)

    expect(summary.total).toBe(5)
    expect(summary.critical).toBe(2)
    expect(summary.risks).toBe(1)
    expect(summary.warnings).toBe(1)
    expect(summary.info).toBe(1)

  })

  it("handles missing severities safely", () => {

    const presentation =
      buildGovernancePresentation([

        signal("1","info")

      ])

    const summary =
      buildGovernanceSummary(presentation)

    expect(summary.total).toBe(1)
    expect(summary.critical).toBe(0)
    expect(summary.risks).toBe(0)
    expect(summary.warnings).toBe(0)
    expect(summary.info).toBe(1)

  })

})
