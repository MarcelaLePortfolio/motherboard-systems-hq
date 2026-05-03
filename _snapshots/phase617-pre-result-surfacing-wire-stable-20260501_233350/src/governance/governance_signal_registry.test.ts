import { buildGovernanceSignalExplanationRegistry } from "./governance_signal_explanation_registry"
import { GOVERNANCE_FIXTURE_MIXED } from "./governance_fixture_corpus"

describe("Governance signal explanation registry", () => {

  it("builds explanations for all signals", () => {

    const result =
      buildGovernanceSignalExplanationRegistry(
        GOVERNANCE_FIXTURE_MIXED
      )

    expect(result.governance_signal_registry.length)
      .toBeGreaterThan(0)

    expect(result.operator_visibility)
      .toBe("full")

    expect(result.cognition_transparency)
      .toBe("enabled")

  })

})
