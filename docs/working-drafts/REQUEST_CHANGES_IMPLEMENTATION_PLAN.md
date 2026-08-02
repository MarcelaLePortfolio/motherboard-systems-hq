# Request Changes Implementation Plan

Status: Implementation Plan

Protected Baseline:

- Branch: feature/new-ui-shell
- Architectural documentation complete
- Approval workflow complete
- Request Changes architecture approved

---

## Objective

Implement Request Changes by composing the existing conversation pipeline.

Do not introduce a second interpretation pipeline.

---

# Phase 1

Server endpoint

Create:

POST /api/request-changes

Responsibilities:

- validate request
- resolve reviewed Living Draft
- resolve authoritative conversation
- invoke existing conversation workflow
- return updated workflow result

Do NOT perform interpretation inside this endpoint.

---

# Phase 2

Conversation workflow

Reuse:

- conversation runtime
- interpretation evidence
- Matilda
- Living Draft synthesis

No duplicated orchestration.

---

# Phase 3

Client

Executive Inbox:

Request Changes

↓

submit feedback

↓

display submitting state

↓

await completion

↓

refresh Approval Request projection

↓

offer navigation to originating conversation

The Executive Inbox must not directly manipulate conversations.

---

# Phase 4

Conversation

The submitted feedback appears as a normal user message.

Matilda responds.

Existing Living Draft updates.

No second Living Draft is created.

---

# Validation

Verify:

✓ feedback appears in originating conversation

✓ Matilda replies

✓ Living Draft updates

✓ Approval projection refreshes

✓ Executive Inbox reflects revised interpretation

✓ Conversation remains authoritative

✓ Living Draft identity preserved

✓ No duplicate interpretation pipeline

✓ No Approval Request persistence introduced

✓ No active conversation silently changes

---

## Explicitly Out of Scope

- Delegate
- Execute
- Canonical Package redesign
- Approval Request persistence
- conversation redesign
- new interpretation runtime
- new Living Draft runtime
- new approval runtime
- active conversation switching
