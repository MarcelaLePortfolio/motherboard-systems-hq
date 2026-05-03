import type { GovernanceDecisionTrace } from "./governance_decision_trace";
import type { GovernanceTimelineEvent } from "./governance_timeline_types";

export interface GovernanceInvestigationReducedState {
  readonly decision_id: string;
  readonly policy_id: string;
  readonly disposition: string;
  readonly explanation_summary: string | null;
  readonly signal_count: number;
  readonly audit_count: number;
  readonly timeline: readonly GovernanceTimelineEvent[];
}

export function reduceGovernanceInvestigation(
  trace: GovernanceDecisionTrace,
): GovernanceInvestigationReducedState {
  return {
    decision_id: trace.decision.decision_id,
    policy_id: trace.decision.policy_id,
    disposition: trace.decision.disposition,
    explanation_summary: trace.explanation?.summary ?? null,
    signal_count: trace.signals.length,
    audit_count: trace.audit.length,
    timeline: trace.timeline,
  };
}
