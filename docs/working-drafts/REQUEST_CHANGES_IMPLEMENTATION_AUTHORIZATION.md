# Request Changes Implementation Authorization

Status: Authorized for Implementation

This document authorizes implementation of the first Request Changes corridor.

Architecture is considered stable.

Implementation must validate the architecture rather than redefine it.

---

## Authorized Objective

Implement the first executable Request Changes workflow.

The implementation must compose existing authoritative runtimes.

No parallel interpretation authority may be introduced.

---

## Authorized Files

Server

- routes/api-request-changes.ts
- server/index.ts

Client

- client/src/approvals/ApprovalsWorkspace.tsx
- client/src/approvals/approvalRequestApi.ts

Only additional files required to support composition may be introduced if implementation proves they are necessary.

---

## Required Runtime Behavior

The endpoint shall:

1. Accept executive revision feedback.

2. Resolve the reviewed Living Draft.

3. Resolve the originating conversation.

4. Validate runtime relationships.

5. Invoke the existing Matilda conversation workflow.

6. Update the existing Living Draft.

7. Return success.

The endpoint must not perform interpretation.

---

## Executive Inbox Behavior

The Executive Inbox shall:

- submit feedback
- display submission progress
- surface failures
- refresh the Approval Request projection
- optionally navigate to the originating conversation after successful completion

The Executive Inbox must never:

- interpret intent
- edit Living Drafts
- edit conversations
- construct runtime lineage

---

## Engineering Constraints

Implementation must reuse:

- conversation runtime
- interpretation evidence
- Matilda interpretation
- Living Draft synthesis

Implementation must not duplicate:

- orchestration
- interpretation
- draft mutation
- projection logic

---

## Corridor Exit Criteria

The corridor is complete when:

✓ Request Changes executes successfully.

✓ Feedback appears in the originating conversation.

✓ Matilda replies.

✓ The existing Living Draft updates.

✓ Approval Requests reflect the revised interpretation.

✓ Executive Inbox refreshes.

✓ No duplicate interpretation pipeline exists.

✓ No architectural invariant is violated.

---

## Stop Conditions

Immediately stop implementation if it requires:

- a second interpretation authority
- a second Living Draft runtime
- Approval Request persistence
- client-managed runtime identities
- conversation redesign
- duplicate orchestration

If any stop condition is encountered:

1. Preserve the implementation state.
2. Record the discovery.
3. Reassess the architecture before proceeding.

