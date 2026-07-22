# Matilda Conversation Identity Decision
## Date: 2026-07-22

## Decision Context

Following:

- Matilda Conversation Identity Findings
- Matilda Conversation Identity Model Options

a decision is required regarding the initial conversation identity model.

No implementation is authorized by this decision alone.

---

# Validated Requirement

Project switching must preserve independent conversation state.

Expected behavior:

Project A selected
→ Project A conversation restored

Project B selected
→ Project B conversation restored

Returning to Project A
→ Project A conversation resumes

---

# Decision

For MVP evaluation, select:

One active conversation per project.

---

# MVP Model

Structure:

Project

→ Active Conversation

→ Conversation History

→ Interpretation Evidence Ledger

→ Living Draft

---

# Rationale

This model:

- Satisfies the validated project switching requirement.
- Introduces the smallest missing primitive.
- Preserves separation between project identity, conversation identity, and lineage identity.
- Avoids introducing unnecessary conversation management complexity during MVP.

---

# Important Boundary

This decision does not mean:

One project can only ever have one conversation.

Future evolution may support:

Project

→ Active Conversation

→ Archived Conversations

→ Multiple Workstreams

The MVP model should preserve migration capability.

---

# Identifier Relationship

Project identity:

`project_id`

Represents:

"What workspace is active?"

---

Conversation identity:

`conversation_id`

Represents:

"What human interaction is active?"

---

Lineage identity:

`lineage_id`

Represents:

"What lifecycle artifacts evolved?"

These identifiers remain separate.

---

# Deferred Questions

Future implementation corridors should determine:

- Conversation creation behavior
- Message persistence schema
- Conversation archival model
- History hydration strategy
- Relationship between conversations and Living Drafts
- Migration path to multiple conversations

---

# Implementation Boundary

Future implementation may introduce:

- Conversation persistence tables
- Conversation API routes
- Conversation hydration logic
- UI state migration

No implementation authorized by this decision alone.
