import { verifyGovernanceReplayStability } from "./governance_cognition_replay_verifier"
import { GOVERNANCE_FIXTURE_WARNING } from "./governance_fixture_corpus"

describe("Governance cognition replay verifier", () => {

  it("produces identical advisory outcomes across replays", () => {

    const result =
      verifyGovernanceReplayStability(
        GOVERNANCE_FIXTURE_WARNING
      )

    expect(result.cognition_replay)
      .toBe("stable")

    expect(result.governance_reliability)
      .toBe("verified")

    expect(result.replay_runs)
      .toBe(5)

  })

})
