/**
 * Phase 466.0 — Governance → Execution Bridge Contract
 *
 * Structural contract only.
 * No runtime wiring.
 * No execution enablement.
 * No authority redistribution.
 */

export interface NormalizedTaskEnvelope {
  id: string | null;
  title: string;
  agent: string;
  status: string;
  notes: unknown;
  source: unknown;
  trace_id: unknown;
  error: unknown;
  meta: unknown;
  created_at: string;
  updated_at: string;
}

export interface NormalizedRunEnvelope {
  run_id: string | null;
  task_id: string | null;
  status?: string | null;
  meta?: unknown;
}

export interface GovernanceDecisionReason {
  code: string;
  value?: string;
}

export interface GovernanceDecisionEnvelope {
  allow: boolean;
  enforce: boolean;
  reasons: GovernanceDecisionReason[];
  confidence: string;
}

export interface GovernanceSignalsEnvelope {
  task_id: string | null;
  run_id: string | null;
  kind: string | null;
  action_tier: string | null;
  attempts: number | null;
  max_attempts: number | null;
  claimed_by: string | null;
  now_ms: number;
}

export interface GovernanceEvaluationEnvelope {
  version: string;
  decision: GovernanceDecisionEnvelope;
  signals: GovernanceSignalsEnvelope;
}

export interface PreparationContextUpdates {
  operatorMode?: string;
  intent?: string;
}

export interface PreparationEnvelope {
  accepted: boolean;
  ctx_updates: PreparationContextUpdates;
  emitted_events: unknown[];
}

export interface GovernanceExecutionBridgeContract {
  intake: {
    task: NormalizedTaskEnvelope;
    run?: NormalizedRunEnvelope;
  };
  governance: GovernanceEvaluationEnvelope;
  preparation: PreparationEnvelope;
}

/**
 * Phase 466.0 invariants:
 * - Intake must already be normalized before governance evaluation.
 * - Governance evaluation must be side-effect free.
 * - Governance output must be explicit and serializable.
 * - Preparation may consume governance output, but may not directly execute work.
 * - No mutation of source intake object across bridge stages.
 * - All stages must remain replay-stable.
 */
