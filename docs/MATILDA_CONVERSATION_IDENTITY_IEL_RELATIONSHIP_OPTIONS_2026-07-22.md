# Matilda Conversation Identity IEL Relationship Options
## Date: 2026-07-22

## Purpose

This document evaluates how future Matilda conversation persistence should relate conversation history to the Interpretation Evidence Ledger (IEL).

It evaluates relationship models before implementation.

No schema changes, database migrations, or implementation are authorized by this document alone.

---

# Design Context

Current architecture:

Project Context
→ Conversation Identity
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

Conversation history and interpretation evidence are related but represent different concepts.

---

# Existing Boundary

## Conversation History

Purpose:

Preserve the human interaction record.

Answers:

"What was said?"

---

## Interpretation Evidence Ledger

Purpose:

Preserve interpreted meaning and evidence.

Answers:

"What was understood and why?"

---

## Lineage Identity

Purpose:

Preserve lifecycle evolution.

Answers:

"What artifacts evolved from this interpretation?"

Conversation identity must remain separate from lineage identity.

---

# Relationship Model A: Message-Level IEL Entries

## Structure

User Message

→ Conversation Message

→ IEL Entry

Matilda Response

→ Conversation Message

→ IEL Entry

---

## Advantages

- Maximum traceability
- Simple association model
- Every interaction is preserved as evidence

---

## Tradeoffs

- IEL may become a transcript archive
- Interpretation evidence becomes mixed with raw conversation history
- Higher persistence volume

---

# Relationship Model B: Interpretation-Level IEL Entries

## Structure

Conversation Message

→ Matilda Interpretation Layer

→ IEL Entry

---

## Advantages

- Preserves IEL as an interpretation evidence system
- Separates raw conversation from interpreted meaning
- Aligns with existing Matilda lifecycle concepts

---

## Tradeoffs

- Requires explicit association between messages and interpretations
- More complex hydration logic

---

# Relationship Model C: Hybrid Relationship

## Structure

Conversation Messages

→ Conversation History

↓

Selected meaningful interactions

→ IEL Entry

---

## Advantages

- Preserves raw history
- Allows important interactions to become evidence
- Reduces unnecessary IEL growth

---

## Tradeoffs

- Requires criteria for selecting IEL-worthy interactions
- Adds classification logic

---

# Evaluation Criteria

Any model should preserve:

- Conversation history as a distinct layer
- IEL as interpretation evidence
- lineage_id as lifecycle identity
- project_id as workspace identity
- conversation_id as interaction identity

---

# Open Questions

Future decision should determine:

- What qualifies as interpretation evidence?
- Should all Matilda responses create evidence?
- Should user corrections create evidence?
- How should summaries relate to IEL?
- How should Living Draft evolution consume conversation context?

---

# Explicit Non-Goals

This document does not authorize:

- Changing IEL semantics
- Creating conversation tables
- Implementing persistence
- Replacing lineage_id
- Changing governance lifecycle

---

# Decision Boundary

Future work should select the relationship model before implementing conversation persistence.

No implementation authorized by this options document alone.
