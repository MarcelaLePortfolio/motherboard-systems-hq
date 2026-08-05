# Candidate Conversation Context Runtime

Status: CANDIDATE MODEL

Origin:

Conversation History Governance Investigation
August 2026

---

# Purpose

Capture the architectural gap identified while investigating how Matilda reconstructs runtime context from persisted conversation history.

This document does not authorize implementation, schema changes, prompt changes, or new governance authority.

---

# Established Repository State

Current runtime behavior already preserves:

- project identity through `project_id`
- conversation identity through `conversation_id`
- interpretation lineage through `interpretation_entry_id`
- conversation turns in durable storage
- project-scoped conversation history retrieval
- Living Draft lineage into Reconciled Intent and Canonical Package artifacts

Existing runtime code currently loads a fixed recent set of conversation turns and passes them into the model prompt.

---

# Identified Gap

The repository does not currently expose a dedicated runtime responsible for governing which persisted conversation turns should influence the current interaction.

No established subsystem was identified for:

- history relevance selection
- correction and supersession handling
- stale-context exclusion
- history summarization
- context-size management
- conversational working-memory assembly
- distinction between recent continuity and durable interpretation

This is an architectural gap rather than evidence of a broken standalone subsystem.

---

# Existing Governance Boundaries

Conversation History answers:

"What was said?"

Interpretation Evidence Ledger answers:

"What was understood and why?"

Living Draft answers:

"What interpretation is currently being developed?"

Canonical Package answers:

"What meaning was explicitly approved?"

These layers must remain distinct.

Raw conversation history must not become equivalent to authoritative interpretation.

Interpretation Evidence Ledger entries must not become raw transcript storage.

---

# Candidate Runtime Responsibility

A possible Conversation Context Runtime may become responsible for assembling bounded conversational working context for a single model invocation.

Conceptually:

Current Message

↓

Active Project and Conversation Identity

↓

Persisted Conversation Turns

↓

History Selection

↓

Correction and Supersession Handling

↓

Bounded Conversation Context

↓

Prompt Construction

The runtime would assemble ephemeral context.

It would not become an authority over conversation history, interpretation, governance, or approved meaning.

---

# Candidate Principles

Future investigation should evaluate the following principles:

- Preserve raw conversation history independently from runtime selection.
- Treat persisted turns as candidate context rather than automatic prompt content.
- Prefer recent continuity without assuming recency establishes relevance.
- Preserve user corrections and explicit reversals.
- Prevent superseded assistant claims from continuing as current truth.
- Keep selection contextual rather than lexical.
- Preserve project and conversation isolation.
- Keep working context ephemeral and reproducible.
- Fail closed when context lineage is ambiguous.

---

# Relationship To Knowledge Capability Routing

Conversation history may eventually act as one knowledge provider within the candidate Knowledge Capability Routing model.

That relationship is not established.

This document does not establish:

- Knowledge Capability ownership
- Knowledge Routing authority
- Context Assembly ownership
- Atlas involvement
- Ellis involvement
- shared multi-agent runtime behavior

---

# First Investigation Corridor

The first implementation-readiness corridor should inspect the current prompt construction path and determine:

- the exact number and ordering of turns supplied
- whether all loaded turns are treated equally
- how corrections are represented
- whether assistant claims can be superseded
- where a narrow selection seam could exist
- what regression evidence is required before modifying behavior

No implementation should begin until that evidence is collected.

---

# Open Questions

- What is the minimum recent-turn window required for fluent continuity?
- How should explicit user corrections supersede earlier turns?
- Should prior assistant replies carry less authority than user statements?
- Should durable interpretations supplement or replace older raw turns?
- When should conversation summaries be created?
- How should selection decisions remain observable and testable?
- Which runtime owns conversation-context selection?
- How should context assembly interact with project retrieval?

---

# Classification

Observation:

SUPPORTED

Architectural Gap:

SUPPORTED

Candidate Runtime:

NOT ESTABLISHED

Implementation:

NOT AUTHORIZED

Reconciliation:

NOT WARRANTED
