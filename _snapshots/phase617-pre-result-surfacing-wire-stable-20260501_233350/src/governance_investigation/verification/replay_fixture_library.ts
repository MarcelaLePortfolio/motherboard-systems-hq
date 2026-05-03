/*
Phase 372 — Replay Fixture Library (boundary coverage expansion)

Purpose:
Provide deterministic fixtures for replay structure verification.

Properties:
- Read only
- Deterministic
- No runtime coupling
- No reducer coupling
- No execution authority
*/

export type ReplayEvent = {
  id?: string;
  sequence?: number;
  timestamp?: string;
  type?: string;
};

export type ReplayFixture = {
  replayId?: string;
  events?: ReplayEvent[];
};

export const VALID_REPLAY_FIXTURE: ReplayFixture = {
  replayId: "fixture-valid-001",
  events: [
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    },
    {
      id: "evt-2",
      sequence: 2,
      timestamp: "2026-01-01T00:01:00.000Z",
      type: "TASK_ROUTED"
    }
  ]
};

export const OUT_OF_ORDER_FIXTURE: ReplayFixture = {
  replayId: "fixture-order-violation",
  events: [
    {
      id: "evt-2",
      sequence: 2,
      timestamp: "2026-01-01T00:01:00.000Z",
      type: "TASK_ROUTED"
    },
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    }
  ]
};

export const DUPLICATE_SEQUENCE_FIXTURE: ReplayFixture = {
  replayId: "fixture-duplicate-seq",
  events: [
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    },
    {
      id: "evt-2",
      sequence: 1,
      timestamp: "2026-01-01T00:01:00.000Z",
      type: "TASK_ROUTED"
    }
  ]
};

export const EMPTY_EVENTS_FIXTURE: ReplayFixture = {
  replayId: "fixture-empty",
  events: []
};

export const MALFORMED_TIMESTAMP_FIXTURE: ReplayFixture = {
  replayId: "fixture-bad-time",
  events: [
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "not-a-time",
      type: "TASK_CREATED"
    }
  ]
};

export const MISSING_FIELD_FIXTURE: ReplayFixture = {
  replayId: "fixture-missing-field",
  events: [
    {
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    }
  ]
};

export const MISSING_SEQUENCE_FIXTURE: ReplayFixture = {
  replayId: "fixture-missing-sequence",
  events: [
    {
      id: "evt-1",
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    }
  ]
};

export const MISSING_TIMESTAMP_FIXTURE: ReplayFixture = {
  replayId: "fixture-missing-timestamp",
  events: [
    {
      id: "evt-1",
      sequence: 1,
      type: "TASK_CREATED"
    }
  ]
};

export const MISSING_TYPE_FIXTURE: ReplayFixture = {
  replayId: "fixture-missing-type",
  events: [
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z"
    }
  ]
};

export const MISSING_REPLAY_ID_FIXTURE: ReplayFixture = {
  events: [
    {
      id: "evt-1",
      sequence: 1,
      timestamp: "2026-01-01T00:00:00.000Z",
      type: "TASK_CREATED"
    }
  ]
};

export const MISSING_EVENTS_ARRAY_FIXTURE: ReplayFixture = {
  replayId: "fixture-missing-events-array"
};
