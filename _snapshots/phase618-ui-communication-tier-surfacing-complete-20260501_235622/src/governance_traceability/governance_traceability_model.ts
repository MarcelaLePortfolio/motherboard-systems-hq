export const GOVERNANCE_TRACEABILITY_STAGES = [
  "signal_classification",
  "policy_routing",
  "decision_pipeline",
  "invariant_evaluation",
  "explanation_capture",
  "audit_capture",
] as const;

export type GovernanceTraceabilityStage =
  (typeof GOVERNANCE_TRACEABILITY_STAGES)[number];

export interface GovernanceTraceabilityRecord {
  decision_id: string;
  signal_type: string;
  policy_route: string | null;
  decision: "ALLOW" | "WARN" | "BLOCK";
  invariants_triggered: string[];
  completed_stages: GovernanceTraceabilityStage[];
  explanation_available: boolean;
  audit_recorded: boolean;
  provenance_summary: string;
  timestamp: number;
}
