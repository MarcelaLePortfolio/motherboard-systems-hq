# Matilda Conversation Identity Implementation Boundary
## Date: 2026-07-22

## Purpose

This document defines the implementation boundary for the Matilda Conversation Identity MVP decision.

It translates the approved design decision into implementation requirements without authorizing implementation.

No schema changes, API changes, or UI migrations are authorized by this document alone.

---

# MVP Implementation Direction

The initial implementation candidate:

One active conversation per project.

Conceptual flow:

Project Context
→ Active Conversation
→ Conversation History
→ Interpretation Evidence Ledger
→ Living Draft

---

# Persistence Boundary

Conversation identity belongs to the cognition/context persistence layer.

Primary persistence location:

`db/main.db`

Reason:

`db/main.db` currently contains:

- project_registry
- active_context
- Interpretation Evidence Ledger
- Living Draft Packages

Conversation identity extends this context layer.

`motherboard.sqlite` remains the governance lifecycle persistence layer.

---

# Required Future Primitives

Future implementation should evaluate introducing:

## Conversation Identity

Purpose:

Represent the active human interaction belonging to a project.

Example identifier:

`conversation_id`

Expected relationship:

project_id
→ conversation_id

---

## Conversation History

Purpose:

Persist the sequence of human and Matilda interactions.

Future evaluation should determine:

- message storage format
- ordering model
- retention rules
- hydration strategy

---

# Required Relationships

Target conceptual model:

Project Registry

→ Project

→ Active Conversation

→ Conversation Messages

→ Interpretation Evidence Ledger

→ Living Draft

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

# UI Migration Boundary

Current behavior:

React component state

→ visible Matilda conversation

Future behavior:

Project Context

→ conversation_id

→ persisted conversation history

→ rendered Matilda conversation

The implementation should preserve the existing workspace architecture.

---

# API Boundary

Future implementation should evaluate APIs for:

- loading the active project conversation
- retrieving conversation history
- appending conversation messages
- associating interactions with project context

Exact route design is deferred.

---

# Matilda Context Hydration Boundary

Future implementation should determine:

How Matilda reconstructs context when a conversation resumes.

Questions include:

- recent messages versus summarized history
- IEL hydration strategy
- Living Draft context inclusion
- context size management

---

# Explicit Non-Goals

This boundary does not authorize:

- Replacing Project Registry
- Replacing Active Context
- Replacing IEL
- Replacing lineage_id
- Changing governance lifecycle
- Implementing multi-thread conversations
- Implementing conversation persistence yet

---

# Implementation Readiness Criteria

Before implementation begins, future work should confirm:

- persistence schema
- API contract
- migration plan from React state
- conversation hydration strategy
- validation criteria

No implementation authorized by this boundary alone.
