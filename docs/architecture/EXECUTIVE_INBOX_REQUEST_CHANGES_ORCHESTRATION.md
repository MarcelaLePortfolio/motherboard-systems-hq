# Executive Inbox Request Changes Orchestration

Status: Architectural Decision

## Decision

Executive Inbox `Request Changes` must process feedback against the reviewed artifact's originating Matilda conversation without silently changing the user's active conversation.

The originating conversation is identified by the artifact's authoritative:

- project_id
- conversation_id
- lineage_id
- draft_package_id

## User Experience

When the executive submits Request Changes:

1. The Executive Inbox validates the artifact identity.
2. The feedback is routed to the originating conversation.
3. The feedback is inserted as a visible user message.
4. Matilda interprets the revision.
5. Matilda responds in the conversation.
6. The existing Living Draft is updated through the shared interpretation pipeline.
7. The Executive Inbox refetches its Approval Request projection.
8. The user is intentionally navigated to, or offered a direct path to, the originating conversation.

The system must never silently switch the active conversation merely to process the request.

## Shared Conversation Workflow

Request Changes and ordinary chat should converge immediately into a single shared Matilda conversation workflow.

That workflow owns:

- conversation validation
- project validation
- lineage validation
- interpretation evidence creation
- project-context retrieval
- Matilda interpretation
- conversation persistence
- Living Draft synthesis
- failure-safe sequencing

Routes may differ.

Interpretation must not.

## Read Model Behavior

Approval Requests remain projections.

The workflow updates only:

Conversation
↓

Interpretation Evidence
↓

Living Draft

The Executive Inbox refreshes by reading the current Approval Request projection.

No Approval Request mutation runtime should be introduced.

## Failure Behavior

If processing fails:

- the current Living Draft remains unchanged
- the originating conversation remains unchanged
- the active conversation remains unchanged
- no Canonical Package is created
- no downstream authority is granted
- the Executive Inbox surfaces the failure to the executive

No partial interpretation state may appear successful.

## Architectural Invariant

The Executive Inbox initiates revision.

The originating Matilda conversation remains the authoritative interpretation surface.

Matilda remains the sole interpreter.

The Living Draft remains the single mutable interpretation artifact.

Everything else—including Approval Requests—is a projection of the current interpreted intent.
