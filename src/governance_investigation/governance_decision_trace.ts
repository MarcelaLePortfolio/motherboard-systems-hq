import type {
  GovernanceAuditReference,
  GovernanceDecisionId,
  GovernanceDecisionRecord,
  GovernanceExplanationRecord,
  GovernancePolicyId,
  GovernanceSignalReference,
} from "./governance_investigation_types";
import {
  createGovernanceInvestigationRecord,
  type GovernanceInvestigationRecord,
} from "./governance_investigation_types";
import {
  buildGovernanceTimeline,
  type GovernanceTimelineEvent,
} from "./governance_timeline_types";

export interface GovernancePolicyReference {
  readonly policy_id: GovernancePolicyId;
  readonly title: string;
  readonly reference_id: string;
}

export interface GovernanceDecisionTraceSeed {
  readonly decision: GovernanceDecisionRecord;
  readonly explanation?: GovernanceExplanationRecord | null;
  readonly audit?: readonly GovernanceAuditReference[];
  readonly signals?: readonly GovernanceSignalReference[];
  readonly policy?: GovernancePolicyReference | null;
}

export interface GovernanceDecisionTrace {
  readonly investigation: GovernanceInvestigationRecord;
  readonly decision: GovernanceDecisionRecord;
  readonly explanation: GovernanceExplanationRecord | null;
  readonly audit: readonly GovernanceAuditReference[];
  readonly signals: readonly GovernanceSignalReference[];
  readonly policy: GovernancePolicyReference | null;
  readonly timeline: readonly GovernanceTimelineEvent[];
}

export function getDecisionTrace(
  _decisionId: GovernanceDecisionId,
  seed: GovernanceDecisionTraceSeed,
): GovernanceDecisionTrace {
  const investigation = createGovernanceInvestigationRecord({
    decision: seed.decision,
    signals: seed.signals,
    explanation: seed.explanation ?? null,
    audit_refs: seed.audit,
  });

  return {
    investigation,
    decision: seed.decision,
    explanation: seed.explanation ?? null,
    audit: Object.freeze([...(seed.audit ?? [])]),
    signals: Object.freeze([...(seed.signals ?? [])]),
    policy: seed.policy ?? null,
    timeline: buildGovernanceTimeline({
      decision: seed.decision,
      explanation: seed.explanation ?? null,
      audits: seed.audit,
      signals: seed.signals,
    }),
  };
}
