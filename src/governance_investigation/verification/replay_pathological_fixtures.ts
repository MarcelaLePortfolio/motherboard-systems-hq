/*
Phase 393 — Replay Pathological Fixture Ordering Correction

Purpose:
Restore deterministic fixture ordering required by verification proofs.
No runtime coupling.
No execution integration.
Verification-only assets.

Safety:
Read-only fixtures.
Deterministic ordering.
No mutation surfaces.
*/

export type ReplayPathologicalFixture = {
  id: string;
  description: string;
  eventSequence: string[];
  expectedViolation: string;
};

export const PATHOLOGICAL_REPLAY_FIXTURES: ReplayPathologicalFixture[] = [
  {
    id: "duplicate-terminal-event",
    description: "Replay contains duplicate terminal state",
    eventSequence: ["task.created", "task.completed", "task.completed"],
    expectedViolation: "REPLAY_DUPLICATE_TERMINAL_EVENT"
  },

  {
    id: "missing-root-event",
    description: "Replay sequence missing required root event",
    eventSequence: ["task.updated", "task.completed"],
    expectedViolation: "REPLAY_ROOT_EVENT_MISSING"
  },

  {
    id: "out-of-order-events",
    description: "Replay contains invalid event ordering",
    eventSequence: ["task.completed", "task.created"],
    expectedViolation: "REPLAY_EVENT_ORDER_VIOLATION"
  },

  {
    id: "unknown-event-type",
    description: "Replay contains undefined event type",
    eventSequence: ["task.created", "task.unknown"],
    expectedViolation: "REPLAY_UNKNOWN_EVENT"
  }
];
