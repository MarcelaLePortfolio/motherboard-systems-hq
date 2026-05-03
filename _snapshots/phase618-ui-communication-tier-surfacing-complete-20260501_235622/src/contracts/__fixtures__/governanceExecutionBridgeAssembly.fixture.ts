import type {
  GovernanceEvaluationEnvelope,
  NormalizedTaskEnvelope,
  PreparationEnvelope,
} from "../governanceExecutionBridgeContract";

export const bridgeAssemblyTaskFixture: NormalizedTaskEnvelope = {
  id: "task.phase466.3.assembly",
  title: "Assembly proof task",
  agent: "atlas",
  status: "queued",
  notes: null,
  source: "phase466.3.fixture",
  trace_id: "trace.phase466.3.fixture",
  error: null,
  meta: { phase: "466.3", purpose: "assembly proof" },
  created_at: "2026-04-10T00:00:00.000Z",
  updated_at: "2026-04-10T00:00:00.000Z",
};

export const bridgeAssemblyGovernanceFixture: GovernanceEvaluationEnvelope = {
  version: "policy-shadow-v1",
  decision: {
    allow: true,
    enforce: false,
    reasons: [],
    confidence: "unknown",
  },
  signals: {
    task_id: "task.phase466.3.assembly",
    run_id: "run.phase466.3.assembly",
    kind: "task",
    action_tier: "B",
    attempts: 0,
    max_attempts: 3,
    claimed_by: null,
    now_ms: 1760000000000,
  },
};

export const bridgeAssemblyPreparationFixture: PreparationEnvelope = {
  accepted: true,
  ctx_updates: {
    operatorMode: "guided",
    intent: "review",
  },
  emitted_events: [
    {
      kind: "bridge.fixture.preparation.ready",
      task_id: "task.phase466.3.assembly",
      run_id: "run.phase466.3.assembly",
    },
  ],
};
