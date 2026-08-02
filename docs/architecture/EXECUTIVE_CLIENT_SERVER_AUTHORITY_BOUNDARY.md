# Executive Client / Server Authority Boundary

Status: Architectural Invariant

## Purpose

The Executive UI must operate on executive concepts.

The server must operate on governance concepts.

The client must not become responsible for understanding the internal architecture of the conversation engine.

---

## Executive Unit of Work

The Executive Inbox presents Approval Requests.

Therefore the executive's unit of work is:

- Approval Request

not

- conversation_id
- draft_package_id
- lineage_id
- interpretation_entry_id

Those identifiers belong to the runtime.

---

## Request Changes Request

The client should submit only the executive artifact identity.

Conceptually:

POST /api/request-changes

{
    approval_request_id,
    feedback
}

The client should never construct or validate runtime lineage.

---

## Server Responsibilities

The server resolves the Approval Request into the authoritative runtime identities.

Those include:

- project_id
- conversation_id
- lineage_id
- draft_package_id

The server validates:

- Approval Request exists
- artifact belongs to the project
- lineage is valid
- conversation exists
- Living Draft exists
- relationships are internally consistent

Only after validation may the server invoke the shared Matilda conversation workflow.

---

## Why

The Executive Inbox should not understand:

- conversation topology
- lineage relationships
- draft persistence
- interpretation evidence
- Living Draft synthesis

Those are implementation details.

The executive simply says:

"I have feedback for this Approval Request."

Everything else belongs to the governance runtime.

---

## Future Compatibility

This boundary allows future executive surfaces to behave identically.

Examples:

- Executive Inbox
- Mobile approvals
- Email approvals
- Slack approvals
- Voice approvals

Every client submits the same executive concept.

Only the server understands the underlying architecture.

---

## Architectural Invariant

Executive clients submit executive artifacts.

Servers resolve governance artifacts.

Interpretation remains entirely server-side.

The client never becomes responsible for understanding the conversation engine's internal architecture.
