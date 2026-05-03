PHASE 180 — OPERATOR REQUEST SCHEMA (COGNITION MODEL)

Purpose:

Define the minimum safe structure required for any future operator-directed execution request.
This is a cognition model only. Nothing in this document authorizes execution.

Core principle:

A request must be understandable, attributable, bounded, and reversible
before it could ever be considered valid.

Operator Request Structure (Conceptual Model)

Required fields:

request_id
Unique identifier for traceability.

operator_id
Human authority originator.

intent_statement
Plain language explanation of what the operator wants done.

Example:
"Restart Atlas worker container"
"Rebuild dashboard container"
"Re-run failed task"

justification
Why the action is needed.

Example:
"Worker stopped responding"
"Telemetry drift detected"
"Deployment validation"

scope_boundary
What the request is allowed to touch.

Example:
container:dashboard
agent:atlas
task_id:1234

risk_classification
Operator-declared risk level.

LOW — read-only
MODERATE — reversible change
HIGH — system mutation

reversibility_statement
How this could be undone if needed.

Example:
"docker compose restart dashboard"
"restore previous image tag"

approval_requirement
Defines if approval is required.

NONE
SELF
DUAL
GOVERNANCE

execution_mode (future concept only)

SIMULATION
DRY_RUN
MANUAL_ASSIST
EXECUTION (not permitted yet)

safety_acknowledgement

Operator must explicitly confirm:

"I acknowledge this request does not self-authorize execution."

Required safety properties:

Human attributable
Intent visible
Bounded scope
Reversible outcome
Traceable identifier
Non-autonomous

Explicitly forbidden in Phase 180:

Automatic approval
Automatic routing
Worker execution
Task mutation
Registry writes
API wiring
Dashboard changes

Phase classification:

Cognition modeling only.

This defines what *would be required* for safety.
This does not allow execution.

Status:

Schema concept defined.
Safe to model validation rules in a later phase.
