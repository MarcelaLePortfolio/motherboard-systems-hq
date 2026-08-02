# Target Conversation Validation Refactor

Status: Implementation Refinement

## Discovery

Inspection of `matilda-conversation-runtime.ts` shows that the runtime already accepts an explicit `conversation_id`.

The implementation gap is not the public API.

The implementation gap is the validation layer.

---

## Existing Flow

createMatildaConversationTurn()

↓

requireActiveMatildaConversation()

↓

continue

listMatildaConversationTurns()

↓

requireActiveMatildaConversation()

↓

continue

---

## Refactored Flow

createMatildaConversationTurn()

↓

requireMatildaConversation()

↓

(optional)

requireActiveMatildaConversation()

↓

continue

listMatildaConversationTurns()

↓

requireMatildaConversation()

↓

(optional)

requireActiveMatildaConversation()

↓

continue

---

## New Validation Primitive

Introduce:

requireMatildaConversation(
    projectId,
    conversationId
)

Responsibilities:

- validate project
- validate conversation existence
- validate project ownership

Responsibilities explicitly excluded:

- active conversation
- navigation
- interpretation
- Living Draft behavior

---

## Active Validation

Refactor:

requireActiveMatildaConversation()

to:

1. call requireMatildaConversation()

2. verify the requested conversation matches the project's active conversation

Behavior must remain identical for all existing callers.

---

## Benefits

- Existing runtime API remains unchanged.
- Existing callers continue to work.
- Request Changes gains explicit-conversation support.
- No duplicate runtime functions are introduced.
- Active-conversation enforcement becomes a composable policy rather than a universal assumption.

---

## Success Criteria

✓ Public runtime API remains stable.

✓ Active-conversation behavior remains unchanged.

✓ Explicit conversation validation becomes reusable.

✓ Existing tests continue to pass.

✓ Request Changes can compose the existing runtime without introducing parallel authority.
