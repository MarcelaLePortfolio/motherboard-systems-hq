import { verifyGovernancePipelineOrder }
from "./governance_pipeline_order_guard"

describe("Governance pipeline ordering", () => {

  it("pipeline structure remains intact", () => {

    const result =
      verifyGovernancePipelineOrder()

    expect(result.pipeline_order)
      .toBe("verified")

    expect(result.governance_contract)
      .toBe("intact")

    expect(result.cognition_sequence)
      .toBe("locked")

  })

})
