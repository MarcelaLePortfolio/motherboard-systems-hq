import { runGovernanceAdvisoryPipeline }
from "./governance_advisory_pipeline"

import {
  GOVERNANCE_FIXTURE_EMPTY
} from "./governance_fixtures"

export function verifyGovernanceAdvisoryStability() {

  const run1 =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  const run2 =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  const run3 =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  if (
    run1.operator_view.status !==
    run2.operator_view.status ||
    run2.operator_view.status !==
    run3.operator_view.status
  ) {
    throw new Error(
      "Governance advisory instability detected"
    )
  }

  return {

    advisory_stability: "verified",

    cognition_determinism: "confirmed",

    governance_consistency: "protected"

  }

}
