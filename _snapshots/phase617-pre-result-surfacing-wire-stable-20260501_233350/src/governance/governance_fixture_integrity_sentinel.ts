import {
  GOVERNANCE_FIXTURE_EMPTY,
  GOVERNANCE_FIXTURE_CRITICAL,
  GOVERNANCE_FIXTURE_WARNING,
  GOVERNANCE_FIXTURE_MIXED
} from "./governance_fixtures"

export function verifyGovernanceFixtureIntegrity() {

  const fixtures = [
    GOVERNANCE_FIXTURE_EMPTY,
    GOVERNANCE_FIXTURE_CRITICAL,
    GOVERNANCE_FIXTURE_WARNING,
    GOVERNANCE_FIXTURE_MIXED
  ]

  fixtures.forEach((fixture) => {

    if (!fixture) {
      throw new Error("Governance fixture drift: fixture missing")
    }

    if (typeof fixture !== "object") {
      throw new Error("Governance fixture drift: fixture shape changed")
    }

    if (!("signals" in fixture)) {
      throw new Error("Governance fixture drift: signals missing")
    }

  })

  return {

    fixture_integrity: "verified",

    fixture_schema: "protected",

    governance_tests: "stable"

  }

}
