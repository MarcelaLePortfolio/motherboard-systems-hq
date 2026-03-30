import type {
  GovernanceAuditReference,
  GovernanceDecisionRecord,
  GovernanceExplanationRecord,
  GovernanceReferenceId,
  GovernanceSignalReference,
} from "./governance_investigation_types";

export type GovernanceTimelineEventType =
  | "decision"
  | "explanation"
  | "audit"
  | "signal"
  | "policy";

export interface GovernanceTimelineEvent {
  readonly type: GovernanceTimelineEventType;
  readonly timestamp: string;
  readonly source: string;
  readonly reference_id: GovernanceReferenceId;
  readonly label: string;
}

export interface GovernanceTimelineSeed {
  readonly decision: GovernanceDecisionRecord;
  readonly explanation?: GovernanceExplanationRecord | null;
  readonly audits?: readonly GovernanceAuditReference[];
  readonly signals?: readonly GovernanceSignalReference[];
}

export function buildGovernanceTimeline(
  seed: GovernanceTimelineSeed,
): readonly GovernanceTimelineEvent[] {
  const events: GovernanceTimelineEvent[] = [
    {
      type: "decision",
      timestamp: seed.decision.timestamp,
      source: "governance_decision",
      reference_id: seed.decision.reference_id,
      label: `${seed.decision.disposition}:${seed.decision.policy_id}`,
    },
    {
      type: "policy",
      timestamp: seed.decision.timestamp,
      source: "governance_policy",
      reference_id: seed.decision.policy_id,
      label: seed.decision.policy_id,
    },
  ];

  for (const signal of seed.signals ?? []) {
    events.push({
      type: "signal",
      timestamp: signal.timestamp,
      source: signal.source,
      reference_id: signal.reference_id,
      label: signal.signal_type,
    });
  }

  if (seed.explanation) {
    events.push({
      type: "explanation",
      timestamp: seed.decision.timestamp,
      source: "governance_explanation",
      reference_id: seed.explanation.reference_id,
      label: seed.explanation.explanation_id,
    });
  }

  for (const audit of seed.audits ?? []) {
    events.push({
      type: "audit",
      timestamp: audit.timestamp,
      source: audit.source,
      reference_id: audit.reference_id,
      label: audit.audit_id,
    });
  }

  return Object.freeze(
    [...events].sort((left, right) =>
      left.timestamp.localeCompare(right.timestamp),
    ),
  );
}
