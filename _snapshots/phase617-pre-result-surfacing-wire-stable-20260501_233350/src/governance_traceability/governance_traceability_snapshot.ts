import type {
  GovernanceTraceabilityRecord,
  GovernanceTraceabilityStage,
} from "./governance_traceability_model";

export interface GovernanceTraceabilitySnapshotInput {
  decision_id: string;
  signal_type: string;
  policy_route?: string | null;
  decision: "ALLOW" | "WARN" | "BLOCK";
  invariants_triggered?: readonly string[];
  completed_stages?: readonly GovernanceTraceabilityStage[];
  explanation?: unknown;
  audit?: unknown;
  provenance_summary?: string;
  timestamp: number;
}

export function buildGovernanceTraceabilitySnapshot(
  input: GovernanceTraceabilitySnapshotInput,
): GovernanceTraceabilityRecord {
  return {
    decision_id: input.decision_id,
    signal_type: input.signal_type,
    policy_route: input.policy_route ?? null,
    decision: input.decision,
    invariants_triggered: [...(input.invariants_triggered ?? [])],
    completed_stages: [...(input.completed_stages ?? [])],
    explanation_available: input.explanation != null,
    audit_recorded: input.audit != null,
    provenance_summary: input.provenance_summary ?? "deterministic governance path",
    timestamp: input.timestamp,
  };
}
