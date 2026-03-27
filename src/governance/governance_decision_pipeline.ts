/*
Phase 329 — Governance Decision Pipeline

Creates a deterministic pipeline connecting:

decision model →
policy router →
result builder →
explanation →
audit record

Purpose:
Create a single governance evaluation path to prevent
future enforcement fragmentation.
*/

import { GovernanceEnforcementDecision } from "./governance_decision_model"

import { routeGovernancePolicy } from "./governance_policy_router"

import { buildGovernanceResult } from "./governance_enforcement_result"

import { buildGovernanceExplanation } from "./governance_explanation_builder"

import { buildGovernanceAuditRecord } from "./governance_audit_log"

export interface GovernancePipelineOutput {

  decision: GovernanceEnforcementDecision

  policy_id: string

  explanation_summary: string

  operator_guidance: string

  audit_ts: number

}

export function runGovernancePipeline(
  decision: GovernanceEnforcementDecision
): GovernancePipelineOutput {

  const policy = routeGovernancePolicy(decision)

  const result = buildGovernanceResult(
    decision,
    policy.reason,
    policy.id,
    policy.description
  )

  const explanation = buildGovernanceExplanation(result)

  const audit = buildGovernanceAuditRecord(result)

  return {

    decision,

    policy_id: policy.id,

    explanation_summary: explanation.summary,

    operator_guidance: explanation.operator_guidance,

    audit_ts: audit.ts

  }

}
