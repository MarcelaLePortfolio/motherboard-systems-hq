/*
Phase 326 — Governance Explanation Builder

Builds deterministic human-readable explanations from
governance enforcement results.

Purpose:
Ensure governance decisions are transparent, explainable,
and operator-safe.
*/

import { GovernanceEnforcementResult } from "./governance_enforcement_result"

export interface GovernanceExplanation {

  summary: string

  detail: string

  operator_guidance: string

  authority_statement: string

}

export function buildGovernanceExplanation(
  result: GovernanceEnforcementResult
): GovernanceExplanation {

  let summary = ""
  let detail = ""
  let operator_guidance = ""

  if (result.decision === "allow") {

    summary = "Governance check passed"

    detail =
      "No governance violations were detected. Execution remains under operator authority."

    operator_guidance =
      "You may proceed if desired. System remains in advisory role."

  }

  if (result.decision === "warn") {

    summary = "Governance review recommended"

    detail =
      "A governance caution signal was detected. Operator review is recommended before execution."

    operator_guidance =
      "Review task intent and confirm execution is appropriate."

  }

  if (result.decision === "block") {

    summary = "Governance protection triggered"

    detail =
      "A critical governance protection condition was detected. Execution should not proceed."

    operator_guidance =
      "Review governance conditions and adjust the task before retrying."

  }

  return {

    summary,

    detail,

    operator_guidance,

    authority_statement:
      "Operator authority remains primary. System enforcement remains bounded."

  }

}
