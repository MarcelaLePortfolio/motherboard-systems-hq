import type { GovernanceExecutionBridgeContract } from "../governanceExecutionBridgeContract";

export const governanceExecutionBridgeContractFixture: GovernanceExecutionBridgeContract = {
  intake: {
    task: {
      id: "task.phase466.fixture",
      title: "Fixture task",
      agent: "atlas",
      status: "queued",
      notes: null,
      source: "phase466.fixture",
      trace_id: "trace.phase466.fixture",
      error: null,
      meta: { phase: "466.1", purpose: "structural compatibility proof" },
      created_at: "2026-04-10T00:00:00.000Z",
      updated_at: "2026-04-10T00:00:00.000Z",
    },
    run: {
      run_id: "run.phase466.fixture",
      task_id: "task.phase466.fixture",
      status: "pending",
      meta: { source: "phase466.fixture" },
    },
  },
  governance: {
    version: "policy-shadow-v1",
    decision: {
      allow: true,
      enforce: false,
      reasons: [],
      confidence: "unknown",
    },
    signals: {
      task_id: "task.phase466.fixture",
      run_id: "run.phase466.fixture",
      kind: "task",
      action_tier: "B",
      attempts: 0,
      max_attempts: 3,
      claimed_by: null,
      now_ms: 1760000000000,
    },
  },
  preparation: {
    accepted: true,
    ctx_updates: {
      operatorMode: "guided",
      intent: "review",
    },
    emitted_events: [
      {
        kind: "bridge.fixture.preparation.ready",
        task_id: "task.phase466.fixture",
        run_id: "run.phase466.fixture",
      },
    ],
  },
};
