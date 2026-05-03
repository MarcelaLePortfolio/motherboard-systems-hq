/*
Phase 294 — Governance Advisory Summary Builder
Pure cognition summarization layer
No routing
No policy enforcement
No mutation
*/

import {
  GovernanceSignal,
  GovernancePresentation
} from "./governance_advisory_presenter"

export type GovernanceSummary = {
  total: number
  critical: number
  risks: number
  warnings: number
  info: number
}

export function buildGovernanceSummary(
  presentation: GovernancePresentation
): GovernanceSummary {

  let critical = 0
  let risks = 0
  let warnings = 0
  let info = 0

  for (const group of presentation.groups) {

    if (group.severity === "critical") {
      critical = group.count
    }

    if (group.severity === "risk") {
      risks = group.count
    }

    if (group.severity === "warning") {
      warnings = group.count
    }

    if (group.severity === "info") {
      info = group.count
    }

  }

  return {
    total: presentation.total_signals,
    critical,
    risks,
    warnings,
    info
  }

}
