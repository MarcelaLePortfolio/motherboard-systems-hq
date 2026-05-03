import { verifyGovernanceAdvisoryContract }
from "./governance_advisory_contract_lock"

describe("Governance advisory contract", () => {

  it("advisory structure remains locked", () => {

    const result =
      verifyGovernanceAdvisoryContract()

    expect(result.advisory_contract)
      .toBe("locked")

    expect(result.governance_shape)
      .toBe("verified")

    expect(result.operator_contract)
      .toBe("protected")

    expect(result.system_contract)
      .toBe("protected")

  })

})
