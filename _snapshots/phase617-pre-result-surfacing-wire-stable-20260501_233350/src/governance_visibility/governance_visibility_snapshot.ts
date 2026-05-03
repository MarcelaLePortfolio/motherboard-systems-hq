import type {
  GovernanceVisibilityDecision,
  GovernanceVisibilityRecord,
} from "./governance_visibility_model";

export interface GovernanceVisibilitySnapshotInput {
  decision_id: string;
  signal_type: string;
  policy_matched?: string | null;
  decision: GovernanceVisibilityDecision;
  invariants_triggered?: readonly string[];
  explanation?: unknown;
  audit?: unknown;
  timestamp: number;
}

export function buildGovernanceVisibilitySnapshot(
  input: GovernanceVisibilitySnapshotInput,
): GovernanceVisibilityRecord {
  return {
    decision_id: input.decision_id,
    signal_type: input.signal_type,
    policy_matched: input.policy_matched ?? null,
    decision: input.decision,
    invariants_triggered: [...(input.invariants_triggered ?? [])],
    explanation_available: input.explanation != null,
    audit_recorded: input.audit != null,
    timestamp: input.timestamp,
  };
}
