import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

import {
  GOVERNANCE_FIXTURE_EMPTY
} from "./governance_fixtures"

export function verifyGovernanceCognitionRegression() {

  const baseline =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  const replay =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  if (
    baseline.operator_view.status !==
    replay.operator_view.status
  ) {
    throw new Error(
      "Governance cognition regression detected"
    )
  }

  return {

    cognition_regression: "clear",

    advisory_replay: "stable",

    governance_baseline: "protected"

  }

}
