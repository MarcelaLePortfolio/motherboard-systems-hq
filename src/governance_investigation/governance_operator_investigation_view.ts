import type { GovernanceDecisionTrace } from "./governance_decision_trace";
import {
  reduceGovernanceInvestigation,
  type GovernanceInvestigationReducedState,
} from "./governance_investigation_reducer";

export interface OperatorGovernanceInvestigationView {
  readonly header: {
    readonly decision_id: string;
    readonly policy_id: string;
    readonly disposition: string;
  };
  readonly summary: GovernanceInvestigationReducedState;
  readonly explanation: string | null;
  readonly references: {
    readonly signal_ids: readonly string[];
    readonly audit_ids: readonly string[];
  };
}

export function buildOperatorGovernanceInvestigationView(
  trace: GovernanceDecisionTrace,
): OperatorGovernanceInvestigationView {
  const summary = reduceGovernanceInvestigation(trace);

  return {
    header: {
      decision_id: trace.decision.decision_id,
      policy_id: trace.decision.policy_id,
      disposition: trace.decision.disposition,
    },
    summary,
    explanation: trace.explanation?.summary ?? null,
    references: {
      signal_ids: Object.freeze(trace.signals.map((signal) => signal.signal_id)),
      audit_ids: Object.freeze(trace.audit.map((audit) => audit.audit_id)),
    },
  };
}
