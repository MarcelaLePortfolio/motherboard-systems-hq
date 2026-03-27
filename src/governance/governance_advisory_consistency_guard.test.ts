import { verifyGovernanceAdvisoryConsistency } from "./governance_advisory_consistency_guard"
import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_CRITICAL
} from "./governance_fixture_corpus"

describe("Governance advisory consistency guard", () => {

  it("matches normal status for empty signals", () => {

    const result =
      verifyGovernanceAdvisoryConsistency(
        GOVERNANCE_FIXTURE_EMPTY
      )

    expect(result.consistency_verified)
      .toBe(true)

  })

  it("matches warning status", () => {

    const result =
      verifyGovernanceAdvisoryConsistency(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.expected_status)
      .toBe("warning")

    expect(result.consistency_verified)
      .toBe(true)

  })

  it("matches critical status", () => {

    const result =
      verifyGovernanceAdvisoryConsistency(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.expected_status)
      .toBe("critical")

    expect(result.consistency_verified)
      .toBe(true)

  })

})
