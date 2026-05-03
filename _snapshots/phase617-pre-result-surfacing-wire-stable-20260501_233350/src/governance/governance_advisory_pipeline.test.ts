/*
Phase 301 — Governance Advisory Pipeline Tests
End-to-end cognition verification
*/

import {
  runGovernanceAdvisoryPipeline
} from "./governance_advisory_pipeline"

function signal(id:string,severity:string){
  return { id, severity }
}

describe("governance advisory pipeline", () => {

  it("builds full advisory chain", () => {

    const result =
      runGovernanceAdvisoryPipeline([

        signal("1","critical"),
        signal("2","warning")

      ])

    expect(result.presentation.total_signals)
      .toBe(2)

    expect(result.digest.highest_severity)
      .toBe("critical")

    expect(result.operator_view.status)
      .toBe("critical")

  })

  it("handles empty signals", () => {

    const result =
      runGovernanceAdvisoryPipeline([])

    expect(result.presentation.total_signals)
      .toBe(0)

    expect(result.digest.highest_severity)
      .toBe(null)

    expect(result.operator_view.status)
      .toBe("healthy")

  })

})
