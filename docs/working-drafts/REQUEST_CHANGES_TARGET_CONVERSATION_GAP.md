# Request Changes Target Conversation Gap

Status: Implementation Discovery

## Protected Baseline

- Branch: `feature/new-ui-shell`
- Commit: `e58d7043`
- DR checkpoint: `20260802_142457`
- Working tree was clean when implementation began.

---

## Discovery

The approved Request Changes architecture requires executive feedback to be processed against the reviewed artifact's originating conversation.

The current conversation runtime assumes operations target the active conversation.

This creates the first implementation gap.

---

## Current Runtime Constraint

Current runtime operations resolve the active conversation.

This prevents Request Changes from safely targeting an arbitrary project-owned conversation while preserving the user's current chat session.

Silently changing the active conversation would violate the documented architecture.

---

## Architectural Meaning

This is **not** evidence that another interpretation pipeline is needed.

It is **not** evidence that another Living Draft runtime is needed.

It is **not** evidence that Approval Requests require persistence.

Instead, it identifies one missing composition capability inside the existing conversation runtime.

---

## Missing Capability

The conversation runtime needs a narrowly-scoped operation that can work against an explicitly identified conversation.

That capability must:

- validate the project
- validate the conversation
- validate their relationship
- operate on that conversation
- preserve the active conversation

The active conversation remains unchanged.

---

## Authorized First Implementation Slice

Implement only:

- target conversation validation
- target conversation retrieval
- target conversation persistence support

The implementation must remain inside the existing conversation runtime.

Do not implement:

- Request Changes endpoint
- Executive Inbox submission
- navigation behavior
- Approval Request changes
- Living Draft redesign
- interpretation changes

---

## Success Criteria

✓ A project-owned conversation can be resolved without becoming active.

✓ Conversation history can be read without changing the active conversation.

✓ Conversation persistence can target that conversation.

✓ Cross-project access remains rejected.

✓ Existing chat behavior remains unchanged.

✓ No duplicate conversation runtime is introduced.

---

## Architectural Outcome

Once this capability exists, Request Changes becomes another client of the existing conversation engine rather than requiring a parallel runtime.
