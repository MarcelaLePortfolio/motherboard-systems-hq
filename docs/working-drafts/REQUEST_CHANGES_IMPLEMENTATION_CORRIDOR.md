# REQUEST CHANGES IMPLEMENTATION CORRIDOR

Status: Authorized Implementation Corridor

## Objective

Implement the first end-to-end Request Changes workflow by composing the existing Matilda conversation pipeline.

This corridor implements architecture that has already been validated.

It does not introduce a new interpretation pipeline.

---

## Scope

Implement only:

- Executive Inbox Request Changes submission
- Request Changes orchestration endpoint
- Conversation insertion
- Existing Matilda interpretation pipeline
- Existing Living Draft update
- Executive Inbox refresh

---

## Workflow

Executive Inbox

↓

Request Changes

↓

POST /api/request-changes

↓

Validate:

- project_id
- conversation_id
- lineage_id
- draft_package_id

↓

Insert executive feedback into the originating Matilda conversation as a user message

↓

Invoke the existing shared Matilda conversation workflow

↓

Interpretation Evidence

↓

Living Draft update

↓

Executive Inbox refetch

↓

Offer or perform navigation to the originating conversation

---

## Required Behavior

The implementation must:

- preserve the existing Living Draft identity
- preserve conversation identity
- preserve lineage
- preserve project identity
- reuse the existing interpretation pipeline
- update only the current Living Draft
- refresh the Approval Request projection by refetching existing read models

---

## Explicitly Out of Scope

Do not implement:

- Delegate
- Execute
- Canonical Package changes
- Approval runtime redesign
- Approval Request persistence
- new interpretation runtime
- new Living Draft runtime
- conversation redesign
- active conversation switching
- automatic approval after revision

---

## Failure Requirements

On failure:

- the Living Draft remains unchanged
- the current active conversation remains unchanged
- the originating conversation remains unchanged
- no Canonical Package is created
- no delegation occurs
- no execution occurs
- the Executive Inbox reports the failure

---

## Success Criteria

✓ Request Changes submits successfully.

✓ Feedback appears as a user message in the originating Matilda conversation.

✓ Matilda responds in that conversation.

✓ Existing Living Draft updates.

✓ Executive Inbox refreshes automatically.

✓ Existing Approval Request projection reflects the revised Living Draft.

✓ No second interpretation pipeline exists.

✓ Active conversation is not silently replaced.

✓ All interpretation continues through the shared Matilda conversation workflow.
