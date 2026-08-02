# Target Conversation Validation Baseline

Status: Implementation Baseline

Protected Commit:

- 418f3cf8

Purpose:

This checkpoint freezes the approved design for explicit target-conversation
validation before implementation begins.

---

## Verified Finding

The existing conversation runtime already exposes the correct public API.

The implementation gap exists only in the validation hierarchy.

No additional public runtime surface is currently justified.

---

## Approved Refactor

Introduce:

requireMatildaConversation()

Responsibilities:

- validate project
- validate conversation existence
- validate project ownership

No additional responsibilities.

---

Refactor:

requireActiveMatildaConversation()

to compose:

requireMatildaConversation()

followed by:

active-conversation verification

Existing runtime behavior must remain unchanged.

---

## Explicit Non-Goals

Do not introduce:

- createMatildaConversationTurnForConversation()
- listMatildaConversationTurnsForConversation()
- duplicate runtime APIs
- alternate conversation persistence
- alternate interpretation runtime

The existing runtime surface remains authoritative.

---

## Authorized Implementation Scope

Files:

- db/matilda-conversation-runtime.ts
- db/matilda-conversation-lineage.test.ts

No additional production files are authorized unless this implementation
reveals a genuine architectural contradiction.

---

## Exit Criteria

✓ Existing public API preserved.

✓ Validation hierarchy becomes composable.

✓ Existing callers remain unchanged.

✓ Explicit conversation validation becomes reusable.

✓ Existing tests pass.

✓ Active conversation semantics remain unchanged.

---

## Engineering Principle

Compose existing authority.

Do not duplicate authority.

This implementation is complete when explicit conversation access is achieved
through validation composition rather than runtime duplication.
