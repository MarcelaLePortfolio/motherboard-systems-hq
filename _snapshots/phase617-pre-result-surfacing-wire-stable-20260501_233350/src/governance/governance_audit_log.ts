/*
Phase 327 — Governance Audit Log

Creates a deterministic governance audit record layer.

Purpose:
Provide traceable governance decisions without affecting execution.
*/

import { GovernanceEnforcementResult } from "./governance_enforcement_result"

export interface GovernanceAuditRecord {

  policy_id: string

  decision: string

  reason: string

  explanation: string

  ts: number

  operator_authority: "preserved"

}

export function buildGovernanceAuditRecord(
  result: GovernanceEnforcementResult
): GovernanceAuditRecord {

  return {

    policy_id: result.policy_id,

    decision: result.decision,

    reason: result.reason,

    explanation: result.explanation,

    ts: result.ts,

    operator_authority: "preserved"

  }

}
