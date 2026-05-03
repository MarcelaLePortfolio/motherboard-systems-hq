import { detectGovernanceContradictions } from "./governance_contradiction_detector"
import {
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_MIXED
} from "./governance_fixture_corpus"

describe("Governance contradiction detector", () => {

  it("detects no contradiction for single-level signals", () => {

    const warning =
      detectGovernanceContradictions(
        GOVERNANCE_FIXTURE_WARNING
      )

    const critical =
      detectGovernanceContradictions(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(warning.contradiction_detected)
      .toBe(false)

    expect(critical.contradiction_detected)
      .toBe(false)

  })

  it("detects contradiction for mixed signals", () => {

    const mixed =
      detectGovernanceContradictions(
        GOVERNANCE_FIXTURE_MIXED
      )

    expect(mixed.contradiction_detected)
      .toBe(true)

  })

})
