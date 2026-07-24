# Matilda Project-Scoped Conversation Runtime Validation
## Date: 2026-07-24

## Purpose

This document validates the runtime implementation resulting from the Matilda Project-Scoped Conversation Identity corridor.

Historical discovery documents:

- MATILDA_PROJECT_SCOPED_CONVERSATION_FINDINGS_2026-07-22.md
- MATILDA_CONVERSATION_IDENTITY_FINDINGS_2026-07-22.md
- MATILDA_CONVERSATION_IDENTITY_MVP_IMPLEMENTATION_PLAN_2026-07-22.md

These documents remain valid as discovery records.

This document records validated runtime state only.

---

# Previously Identified Gap

The previously identified runtime gap was:

Project Context
→ Matilda Chat
→ Interpretation Evidence Ledger

The missing boundary was:

Conversation Identity

The required target boundary was:

Project Context
→ Conversation Identity
→ Conversation History
→ Matilda Interpretation
→ Living Draft

---

# Runtime Validation Evidence

## Conversation Persistence

Validated components:

- `db/matilda-conversation-runtime.ts`

Runtime persistence primitives:

- `matilda_conversations`
- `matilda_active_conversation_context`
- `matilda_conversation_turns`

Validated behavior:

- Conversation identity persists independently from browser component state.
- Conversation turns are stored with project and conversation association.

---

## Project Isolation

Validated components:

- `/api/chat/history`
- `listMatildaConversationTurns()`
- `matilda_conversation_turns`

Runtime evidence:

Project A conversation history remains associated with Project A.

Project B conversation history remains associated with Project B.

Returning to a project resolves its persisted conversation state through project-scoped conversation lookup.

---

## Chat Runtime Binding

Validated components:

- `routes/api-chat.ts`
- `matilda-chat-stub.ts`

Validated runtime flow:

Project Context
→ project_id
→ conversation_id
→ Matilda runtime
→ Interpretation Evidence Ledger entry
→ Conversation turn persistence

Chat requests now carry durable conversation identity.

---

## Interpretation Evidence Boundary

Validated separation:

Conversation transcript storage:

`matilda_conversation_turns`

Interpretation evidence storage:

`matilda_interpretation_evidence_ledger`

Association:

`interpretation_entry_id`

The Interpretation Evidence Ledger remains an interpretation layer rather than becoming a raw transcript archive.

---

## Living Draft Boundary

Validated components:

- `db/matilda-chat-draft-integration.ts`

Validated behavior:

Living Draft integration consumes conversation-scoped evidence.

Inputs include:

- project_id
- conversation_id
- evidence_entry_ids

Cross-project evidence mixing is prevented through scoped conversation retrieval.

---

# Runtime Expansion Beyond Original MVP Assumption

The original MVP direction evaluated one active conversation per project.

Current runtime supports:

- multiple conversation identities per project
- active conversation selection
- conversation switching

The validated requirement remains:

Project-scoped conversation isolation.

Multiple conversation support is considered an expanded capability, not a replacement of the original boundary.

---

# Remaining Deferred Corridor

The following remain future work:

- richer conversation summarization
- long-term context compression
- conversation memory strategy
- conflict resolution between historical conversation context and verified runtime evidence

These are hydration-quality questions, not conversation identity questions.

---

# Status

Project-scoped Conversation Identity runtime boundary validated.

Conversation Identity is no longer an unimplemented architectural gap.

Future work should extend conversation hydration quality rather than recreate the identity layer.
