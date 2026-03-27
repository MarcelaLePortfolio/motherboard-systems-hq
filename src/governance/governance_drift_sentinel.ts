import {
  runGovernanceAdvisoryPipeline
} from "./governance_advisory_pipeline"

import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_MIXED
} from "./governance_fixtures"

export function runGovernanceDriftSentinel() {

  const empty =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_EMPTY
    )

  const critical =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_CRITICAL
    )

  const warning =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_WARNING
    )

  const mixed =
    runGovernanceAdvisoryPipeline(
      GOVERNANCE_FIXTURE_MIXED
    )

  return {

    empty_status:
      empty.operator_view.status,

    critical_status:
      critical.operator_view.status,

    warning_status:
      warning.operator_view.status,

    mixed_status:
      mixed.operator_view.status

  }

}
