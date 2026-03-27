import { computeGovernanceSignalStabilityIndex } from "./governance_signal_stability_index"
import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_CRITICAL
} from "./governance_fixture_corpus"

describe("Governance stability index", () => {

  it("is high when no signals exist", () => {

    const result =
      computeGovernanceSignalStabilityIndex(
        GOVERNANCE_FIXTURE_EMPTY
      )

    expect(result.governance_stability_index)
      .toBe(100)

    expect(result.stability_band)
      .toBe("stable")

  })

  it("decreases when warning signals exist", () => {

    const result =
      computeGovernanceSignalStabilityIndex(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.governance_stability_index)
      .toBeLessThan(100)

  })

  it("drops further with critical signals", () => {

    const result =
      computeGovernanceSignalStabilityIndex(
        GOVERNANCE_FIXTURE_CRITICAL
      )

    expect(result.governance_stability_index)
      .toBeLessThan(70)

  })

})
