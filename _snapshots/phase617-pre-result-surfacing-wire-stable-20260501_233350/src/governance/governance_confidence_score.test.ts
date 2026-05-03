import { computeGovernanceOperatorConfidence } from "./governance_operator_confidence_score"
import { GOVERNANCE_FIXTURE_CRITICAL } from "./governance_fixture_corpus"

describe("Governance confidence scoring", () => {

  it("reduces confidence when critical signals exist", () => {

    const result =
      computeGovernanceOperatorConfidence(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.governance_confidence_score)
      .toBeLessThan(100)

    expect(result.governance_confidence_band)
      .not.toBe("high")

  })

})
