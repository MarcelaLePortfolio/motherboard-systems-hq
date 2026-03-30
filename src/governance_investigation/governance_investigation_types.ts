export type GovernanceReferenceId = string;
export type GovernanceDecisionId = string;
export type GovernancePolicyId = string;
export type GovernanceExplanationId = string;
export type GovernanceAuditId = string;
export type GovernanceSignalId = string;

export type GovernanceDecisionDisposition =
  | "allow"
  | "deny"
  | "escalate"
  | "defer"
  | "observe";

export interface GovernanceSignalReference {
  readonly signal_id: GovernanceSignalId;
  readonly signal_type: string;
  readonly source: string;
  readonly reference_id: GovernanceReferenceId;
  readonly timestamp: string;
}

export interface GovernanceDecisionRecord {
  readonly decision_id: GovernanceDecisionId;
  readonly timestamp: string;
  readonly policy_id: GovernancePolicyId;
  readonly disposition: GovernanceDecisionDisposition;
  readonly reference_id: GovernanceReferenceId;
}

export interface GovernanceExplanationRecord {
  readonly explanation_id: GovernanceExplanationId;
  readonly decision_id: GovernanceDecisionId;
  readonly summary: string;
  readonly reference_id: GovernanceReferenceId;
}

export interface GovernanceAuditReference {
  readonly audit_id: GovernanceAuditId;
  readonly reference_id: GovernanceReferenceId;
  readonly timestamp: string;
  readonly source: string;
}

export interface GovernanceInvestigationRecord {
  readonly decision_id: GovernanceDecisionId;
  readonly timestamp: string;
  readonly policy_id: GovernancePolicyId;
  readonly signals: readonly GovernanceSignalReference[];
  readonly decision: GovernanceDecisionRecord;
  readonly explanation_id: GovernanceExplanationId | null;
  readonly audit_refs: readonly GovernanceAuditReference[];
}

export interface GovernanceInvestigationSeed {
  readonly decision: GovernanceDecisionRecord;
  readonly signals?: readonly GovernanceSignalReference[];
  readonly explanation?: GovernanceExplanationRecord | null;
  readonly audit_refs?: readonly GovernanceAuditReference[];
}

export function createGovernanceInvestigationRecord(
  seed: GovernanceInvestigationSeed,
): GovernanceInvestigationRecord {
  return {
    decision_id: seed.decision.decision_id,
    timestamp: seed.decision.timestamp,
    policy_id: seed.decision.policy_id,
    signals: Object.freeze([...(seed.signals ?? [])]),
    decision: seed.decision,
    explanation_id: seed.explanation?.explanation_id ?? null,
    audit_refs: Object.freeze([...(seed.audit_refs ?? [])]),
  };
}
