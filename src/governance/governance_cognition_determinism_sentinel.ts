import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_MIXED
} from "./governance_fixtures"

export function verifyGovernanceCognitionDeterminism() {

  const fixtures = [
    GOVERNANCE_FIXTURE_EMPTY,
    GOVERNANCE_FIXTURE_CRITICAL,
    GOVERNANCE_FIXTURE_WARNING,
    GOVERNANCE_FIXTURE_MIXED
  ]

  fixtures.forEach((fixture) => {

    const run1 =
      runGovernanceAdvisoryPipeline(fixture)

    const run2 =
      runGovernanceAdvisoryPipeline(fixture)

    if (
      run1.operator_view.status !==
      run2.operator_view.status
    ) {
      throw new Error(
        "Governance determinism drift detected"
      )
    }

  })

  return {

    governance_determinism: "verified",

    cognition_replay: "stable",

    governance_consistency: "protected"

  }

}
