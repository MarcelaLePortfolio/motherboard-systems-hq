import * as assert from "node:assert/strict";

import { assembleMissionReadModel } from "./mission-read-model-assembler";

const mission = assembleMissionReadModel({
  package_id: "pkg-lifecycle-timeline-test",
  package_version: 1,
  project_id: null,
  conversation_id: null,
  lifecycle_state: "ASSIGNED",
  lifecycle_event_count: 3,
  lifecycle_events: [
    {
      transition_authorization: "EXECUTION_AUTHORIZED",
      persisted_at: "2026-07-28T12:03:00.000Z",
    },
    {
      transition_authorization: "DELEGATION_AUTHORIZED",
      persisted_at: "2026-07-28T12:01:00.000Z",
    },
    {
      transition_authorization: "ASSIGNMENT_AUTHORIZED",
      persisted_at: "2026-07-28T12:02:00.000Z",
    },
  ],
  integrity_warnings: [],
});

assert.deepEqual(
  mission.timeline.map((t) => t.event_type),
  [
    "DELEGATION_AUTHORIZED",
    "ASSIGNMENT_AUTHORIZED",
    "EXECUTION_AUTHORIZED",
  ],
);

assert.deepEqual(
  mission.timeline.map((t) => t.timestamp),
  [
    "2026-07-28T12:01:00.000Z",
    "2026-07-28T12:02:00.000Z",
    "2026-07-28T12:03:00.000Z",
  ],
);

console.log("Mission lifecycle timeline assembly passed.");
