# Request Changes Implementation Checklist

Status: Ready for Implementation

This checklist is the execution contract for the Request Changes corridor.

Architectural decisions are complete.

Do not revisit architecture unless implementation exposes a genuine contradiction.

---

## Phase 1 — Server Endpoint

Create:

POST /api/request-changes

Acceptance Criteria

□ Endpoint validates request payload.

□ Endpoint resolves the reviewed Living Draft.

□ Endpoint resolves the originating conversation.

□ Endpoint never trusts client-supplied runtime relationships.

□ Endpoint composes existing runtime.

□ Endpoint performs no interpretation.

STOP if new interpretation logic appears necessary.

---

## Phase 2 — Shared Conversation Workflow

Reuse existing runtime.

Do not duplicate:

□ interpretation evidence creation

□ conversation persistence

□ Living Draft synthesis

□ Matilda interpretation

□ project context retrieval

Acceptance Criteria

□ Existing conversation workflow remains authoritative.

□ No second interpretation pipeline exists.

STOP if orchestration must be duplicated.

---

## Phase 3 — Executive Inbox

Implement:

□ Request Changes submit action

□ submitting state

□ inline error handling

□ Inbox refresh

□ offer navigation to originating conversation

Acceptance Criteria

□ Inbox never edits conversations directly.

□ Inbox never edits Living Drafts directly.

□ Inbox never interprets intent.

---

## Phase 4 — Conversation

Acceptance Criteria

□ Executive feedback appears as a normal user message.

□ Matilda replies normally.

□ Clarification questions continue naturally when required.

□ Existing Living Draft updates.

□ Living Draft identity is preserved.

□ No second Living Draft is created.

---

## Phase 5 — Projection

Acceptance Criteria

□ Approval Request projection updates automatically.

□ Executive Inbox reflects revised interpretation.

□ No Approval Request persistence introduced.

□ Projection remains read-only.

---

## Phase 6 — Validation

Verify:

□ Request Changes succeeds.

□ Conversation receives feedback.

□ Matilda responds.

□ Living Draft updates.

□ Approval projection refreshes.

□ Inbox refreshes.

□ Duplicate interpretation pipeline does not exist.

□ Active conversation is never silently switched.

□ Conversation remains the system of record.

□ Living Draft remains the current interpretation.

□ Canonical Package behavior remains unchanged.

---

## Abort Conditions

Stop immediately if implementation requires:

- second interpretation pipeline
- second Living Draft runtime
- Approval Request persistence
- conversation redesign
- Executive Inbox interpretation logic
- client-managed runtime identities
- duplicate orchestration

If any abort condition is encountered:

1. Stop implementation.
2. Preserve the current baseline.
3. Document the discovery.
4. Reassess architecture before continuing.
