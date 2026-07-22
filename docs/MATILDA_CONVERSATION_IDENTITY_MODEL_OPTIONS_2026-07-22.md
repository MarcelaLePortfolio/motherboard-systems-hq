# Matilda Conversation Identity Model Options
## Date: 2026-07-22

## Discovery Context

Following the Matilda Conversation Identity Findings corridor, the next question is how a durable conversation identity should be modeled.

This document evaluates possible conversation identity models before implementation.

No implementation is authorized by this document alone.

---

# Current Validated Architecture

Current system:

Project Context
→ Matilda Chat
→ Interpretation Evidence Ledger
→ Living Draft

Missing layer:

Project Context
→ Conversation Identity
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

---

# Existing Identifier Boundaries

## Project Identity

Purpose:

Represents the active workspace/project context.

Identifier:

`project_id`

Meaning:

"What project does this interaction belong to?"

---

## Conversation Identity

Future primitive.

Purpose:

Represents an ongoing human interaction context.

Identifier:

`conversation_id`

Meaning:

"What conversation does this interaction belong to?"

---

## Lineage Identity

Existing primitive.

Purpose:

Represents lifecycle evolution of artifacts.

Identifier:

`lineage_id`

Meaning:

"What chain of work evolved from this interpretation?"

Conversation identity should not replace lineage identity.

---

# Model Option A: One Active Conversation Per Project

## Structure

Project

→ Conversation

→ Messages

→ Interpretation Evidence Ledger

→ Living Draft

## Behavior

Project A selected:
→ restore Project A conversation

Project B selected:
→ restore Project B conversation

Return to Project A:
→ resume Project A conversation

## Advantages

- Simplest MVP model
- Matches current workspace concept
- Minimal UI complexity
- Natural extension of Active Context

## Tradeoffs

- No parallel discussions within one project
- Requires a future migration path if projects need multiple concurrent conversation threads

---

# Model Option B: Multiple Conversations Per Project

## Structure

Project

→ Conversation A

→ Conversation B

→ Conversation C

Each conversation:

→ Messages

→ Interpretation Evidence Ledger

→ Potential Living Draft evolution

## Advantages

- Supports multiple workstreams
- Matches familiar chat thread behavior
- More flexible long term

## Tradeoffs

- Requires conversation selection UX
- Requires conversation lifecycle management
- More complex MVP boundary

---

# Model Option C: Conversation As Temporary Session

## Structure

Project

→ Session

→ Messages

→ Optional persistence

## Advantages

- Simpler than full conversation management
- Useful for transient interactions

## Tradeoffs

- Does not satisfy durable project memory requirements
- Weak relationship to Living Draft evolution

---

# Evaluation

Required behavior:

Project A selected
→ Project A conversation restored

Project B selected
→ Project B conversation restored

Returning to Project A
→ Project A conversation resumes

Any acceptable model must preserve this behavior.

---

# Identifier Relationship

Recommended separation:

project_id

answers:

"What workspace is active?"

---

conversation_id

answers:

"What human interaction is active?"

---

lineage_id

answers:

"What lifecycle artifacts evolved?"

These identifiers represent different dimensions and should remain separate.

---

# Deferred Design Questions

Before implementation, future corridor should determine:

- Whether MVP uses one conversation per project or multiple conversations
- Conversation creation rules
- Conversation archival rules
- Message persistence schema
- How conversation history hydrates Matilda
- How conversations relate to Living Draft evolution
- Whether one conversation can produce multiple lineages

---

# Current Recommendation

For MVP evaluation:

Recommend evaluating Model Option A as the initial implementation candidate.

One active conversation per project.

Reason:

It satisfies the validated requirement:

Project switching should restore project-specific conversation state.

It introduces the smallest new primitive while preserving future expansion to multiple conversations.

No implementation authorized by this document alone.
