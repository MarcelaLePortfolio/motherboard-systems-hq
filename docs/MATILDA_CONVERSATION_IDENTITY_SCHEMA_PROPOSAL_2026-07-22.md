# Matilda Conversation Identity Schema Proposal
## Date: 2026-07-22

## Purpose

This document proposes the persistence model required to support the Matilda Conversation Identity MVP direction.

It defines possible future primitives without creating schema changes.

No database migrations, API changes, or implementation are authorized by this proposal alone.

---

# Design Context

Completed decisions:

- Project Context remains the workspace identity layer.
- Conversation Identity is a missing cognition/context layer.
- MVP direction is one active conversation per project.
- Conversation identity must remain separate from lineage identity.

Target conceptual flow:

Project Context
→ Conversation Identity
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

---

# Persistence Boundary

Primary database:

`db/main.db`

Reason:

The conversation layer belongs to cognition/context persistence.

Current related primitives:

- project_registry
- active_context
- matilda_interpretation_evidence_ledger
- matilda_living_draft_packages

`motherboard.sqlite` remains reserved for governance lifecycle artifacts.

---

# Proposed Future Primitives

## conversations

Purpose:

Represent a durable human interaction context belonging to a project.

Conceptual fields:

- conversation_id
- project_id
- status
- created_at
- updated_at
- last_active_at

Relationship:

project_id
→ conversation_id

---

## conversation_messages

Purpose:

Represent the ordered history of interactions within a conversation.

Conceptual fields:

- message_id
- conversation_id
- actor
- message_role
- content
- created_at

Possible roles:

- user
- matilda

---

# Relationship Model

Target:

project_registry

↓

conversations

↓

conversation_messages

↓

Interpretation Evidence Ledger

↓

Living Draft Packages

---

# Identifier Boundaries

## project_id

Represents:

"What workspace/project is active?"

---

## conversation_id

Represents:

"What human interaction is active?"

---

## lineage_id

Represents:

"What lifecycle artifacts evolved?"

These identifiers must remain separate.

---

# IEL Relationship

Future implementation should determine how conversation messages relate to IEL entries.

Possible models:

## Model A

Each message creates a corresponding IEL entry.

Conversation message

→ Interpretation Evidence Ledger

Advantages:

- Strong traceability

Tradeoffs:

- Higher persistence volume

---

## Model B

Only interpreted interactions create IEL entries.

Conversation message

→ Matilda interpretation

→ IEL entry

Advantages:

- Keeps IEL focused on interpretation events

Tradeoffs:

- Requires additional association logic

---

# Living Draft Relationship

Future implementation should determine whether:

- conversations directly reference living drafts
- living drafts reference originating conversations
- both remain indirectly related through IEL

Current recommendation:

Do not replace lineage relationships.

---

# Hydration Considerations

Future implementation must determine how Matilda resumes a conversation.

Possible inputs:

- recent conversation messages
- summarized conversation state
- IEL-derived context
- Living Draft context

---

# Open Schema Questions

Before implementation:

- Should one project have one active conversation record?
- Should archived conversations exist in MVP?
- Should messages store raw content only or derived metadata?
- How are deleted conversations handled?
- How are conversation summaries generated?
- How are conversations associated with Living Draft evolution?

---

# Explicit Non-Goals

This proposal does not authorize:

- Creating database tables
- Modifying `db/main.db`
- Replacing IEL
- Replacing lineage_id
- Changing governance lifecycle
- Implementing multi-thread conversations

---

# Implementation Readiness Criteria

Before schema implementation:

- finalize table relationships
- finalize message persistence rules
- finalize IEL association strategy
- finalize hydration strategy
- validate migration path from React state

No implementation authorized by this proposal alone.
