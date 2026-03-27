/*
Phase 304 — Governance Fixture Corpus Tests
Deterministic corpus validation
*/

import {
  runGovernanceAdvisoryPipeline
} from "./governance_advisory_pipeline"

import {

  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_HEALTHY,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_RISK,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_MIXED,
  GOVERNANCE_FIXTURE_DUPLICATES

} from "./governance_fixture_corpus"

describe("governance fixture corpus", () => {

  it("empty corpus is healthy", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_EMPTY
      )

    expect(result.operator_view.status)
      .toBe("healthy")

  })

  it("critical corpus is critical", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.operator_view.status)
      .toBe("critical")

  })

  it("risk corpus shows attention", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_RISK
      )

    expect(result.operator_view.status)
      .toBe("attention")

  })

  it("mixed corpus prioritizes highest severity", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_MIXED
      )

    expect(result.operator_view.status)
      .toBe("critical")

  })

  it("duplicate warnings remain attention", () => {

    const result =
      runGovernanceAdvisoryPipeline(
        GOVERNANCE_FIXTURE_DUPLICATES
      )

    expect(result.operator_view.status)
      .toBe("attention")

  })

})
