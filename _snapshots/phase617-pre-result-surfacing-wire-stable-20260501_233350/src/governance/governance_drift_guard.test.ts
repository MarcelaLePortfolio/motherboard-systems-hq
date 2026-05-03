import { runGovernanceDriftGuard }
from "./governance_drift_guard"

describe("Governance drift guard", () => {

  it("governance pipeline remains stable", () => {

    const result =
      runGovernanceDriftGuard()

    expect(result.governance_status)
      .toBe("governance-stable")

    expect(result.sentinel)
      .toBe("active")

    expect(result.drift_detection)
      .toBe("locked")

    expect(result.cognition_pipeline)
      .toBe("protected")

  })

})
