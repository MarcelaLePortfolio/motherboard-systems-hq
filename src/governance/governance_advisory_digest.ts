/*
Phase 296 — Governance Advisory Digest
Operator cognition digest builder
Read-only summarization layer
No routing / no enforcement
*/

import {
  GovernancePresentation
} from "./governance_advisory_presenter"

import {
  GovernanceSummary,
  buildGovernanceSummary
} from "./governance_advisory_summary_builder"

export type GovernanceDigest = {
  summary: GovernanceSummary
  highest_severity: string | null
}

const SEVERITY_PRIORITY = [
  "critical",
  "risk",
  "warning",
  "info"
]

export function buildGovernanceDigest(
  presentation: GovernancePresentation
): GovernanceDigest {

  const summary =
    buildGovernanceSummary(presentation)

  let highest: string | null = null

  for (const level of SEVERITY_PRIORITY) {

    const found =
      presentation.groups.find(
        g => g.severity === level
      )

    if (found && found.count > 0) {
      highest = level
      break
    }

  }

  return {
    summary,
    highest_severity: highest
  }

}
