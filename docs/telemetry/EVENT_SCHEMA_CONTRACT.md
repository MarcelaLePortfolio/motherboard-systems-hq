TELEMETRY EVENT SCHEMA CONTRACT
Phase 68 — Drift Detection Foundation
Date: 2026-03-16

────────────────────────────────

PURPOSE

Define canonical telemetry event shapes to prevent silent reducer breakage.

This document establishes the expected structure of telemetry events and
serves as the reference contract for Phase 68 drift detection tooling.

Detection scripts will validate runtime telemetry against this contract.

NO RUNTIME BEHAVIOR CHANGES.
DOCUMENTATION + VALIDATION ONLY.

────────────────────────────────

CORE EVENT STREAMS

Primary stream:

/events/task-events

Future streams:

/events/system-metrics
/events/agent-status

────────────────────────────────

TASK EVENT CANONICAL SCHEMA

Required fields:

event_type      string
task_id         string
run_id          string
ts              number (unix ms)
state           string

Optional fields:

actor           string
lease_epoch     number
metadata        object

Allowed event types:

task.created
task.started
task.running
task.completed
task.failed
task.cancelled

Terminal states:

completed
failed
cancelled

Non-terminal states:

created
started
running

Invariant rules:

task_id must always exist
run_id must always exist
ts must always exist
event_type must always exist

Reducers assume:

Terminal events remove task from active set.
Non-terminal events add or maintain active state.

────────────────────────────────

SYSTEM METRICS SCHEMA (PLANNED)

Required fields:

metric_name     string
metric_value    number
ts              number

Optional:

labels          object
source          string

────────────────────────────────

AGENT STATUS SCHEMA (PLANNED)

Required:

agent_name      string
status          string
ts              number

Allowed agents:

Matilda
Atlas
Cade
Effie

Allowed status:

healthy
degraded
offline
starting

────────────────────────────────

DRIFT CONDITIONS (PHASE 68 DETECTION TARGETS)

Schema drift:

Missing required field
Unknown required field
Field type mismatch

Event drift:

Unknown event type
Unexpected terminal ordering
Duplicate terminal events

Reducer risk drift:

Missing state field
Missing task_id
Missing run_id

Contract drift:

Producer emits incompatible payload

────────────────────────────────

VALIDATION RULES

Validation must:

Fail on missing required field
Warn on unknown field
Fail on invalid type
Warn on unknown event_type

Detection is NON-BLOCKING in Phase 68.

Future phases may enforce.

────────────────────────────────

NEXT ARTIFACTS

scripts/_local/phase68_telemetry_contract_check.sh

scripts/_local/phase68_event_schema_validator.ts

Future:

Replay corpus validation.

────────────────────────────────

PHASE STATUS

Telemetry contract defined.

Ready for validator implementation.

