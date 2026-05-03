import { buildGovernanceOperatorExplanation } from "./governance_operator_explanation_layer"
import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_CRITICAL
} from "./governance_fixture_corpus"

describe("Governance operator explanation layer", () => {

  it("returns normal explanation for empty signals", () => {

    const result =
      buildGovernanceOperatorExplanation(
        GOVERNANCE_FIXTURE_EMPTY
      )

    expect(result.governance_status)
      .toBe("normal")

  })

  it("returns warning explanation", () => {

    const result =
      buildGovernanceOperatorExplanation(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.governance_status)
      .toBe("warning")

  })

  it("returns critical explanation", () => {

    const result =
      buildGovernanceOperatorExplanation(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.governance_status)
      .toBe("critical")

  })

})
