/*
Phase 306 — Governance Drift Sentinel
Detects advisory pipeline drift using fixture expectations
Deterministic cognition guard only
*/

import {
  runGovernanceAdvisoryPipeline
} from "./governance_advisory_pipeline"

import {

  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_MIXED

} from "./governance_fixture_corpus"

describe("governance drift sentinel", () => {

  it("empty remains healthy", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_EMPTY
      )

    expect(result.operator_view.status)
      .toBe("healthy")

  })

  it("critical remains critical", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.operator_view.status)
      .toBe("critical")

  })

  it("warning remains attention", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.operator_view.status)
      .toBe("attention")

  })

  it("mixed remains critical", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_MIXED
      )

    expect(result.operator_view.status)
      .toBe("critical")

  })

})
