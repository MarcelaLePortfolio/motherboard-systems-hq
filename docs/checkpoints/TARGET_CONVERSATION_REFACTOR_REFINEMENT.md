# Target Conversation Refactor Refinement

Status: Implementation Refinement

Protected Baseline

- Branch: feature/new-ui-shell
- Commit: c419708d

---

## Inspection Result

The implementation inspection produced a simpler solution than originally proposed.

The runtime already contains:

getConversationForProject(projectId, conversationId)

This helper already:

- validates project ownership
- validates conversation existence
- returns the resolved conversation

Therefore a second validation primitive is unnecessary.

---

## Revised Implementation

Refactor:

requireActiveMatildaConversation()

to compose:

getConversationForProject()

followed by:

active conversation verification

No new lookup helper is introduced.

---

## Runtime Flow

Existing

Operation

↓

requireActiveMatildaConversation()

↓

active conversation lookup

↓

continue

Revised

Operation

↓

getConversationForProject()

↓

requireActiveMatildaConversation()

↓

active conversation verification

↓

continue

---

## Benefits

- Zero duplicate lookup logic.
- Existing helper becomes authoritative.
- Public runtime API remains unchanged.
- Existing callers remain unchanged.
- Request Changes gains explicit conversation capability through composition.

---

## Authorized Scope

Only:

- db/matilda-conversation-runtime.ts
- db/matilda-conversation-lineage.test.ts

No additional production files.

---

## Success Criteria

✓ Existing public API unchanged.

✓ Existing helper reused.

✓ Active conversation semantics unchanged.

✓ Explicit project conversation access supported.

✓ Existing lineage tests extended.

✓ No duplicate runtime authority introduced.

---

## Engineering Principle

Prefer existing authority over new authority.

Prefer composition over duplication.

Prefer the smallest validated refactor that satisfies the architecture.
