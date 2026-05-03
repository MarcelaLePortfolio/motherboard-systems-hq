export type GovernanceVisibilityDecision = "ALLOW" | "WARN" | "BLOCK";

export interface GovernanceVisibilityRecord {
  decision_id: string;
  signal_type: string;
  policy_matched: string | null;
  decision: GovernanceVisibilityDecision;
  invariants_triggered: string[];
  explanation_available: boolean;
  audit_recorded: boolean;
  timestamp: number;
}
