# Semantic History Inventory
## Behavioral Integration — Corridor 3
### Sub-corridor: Current Semantic History Inventory

Status: COMPLETE

Date: 2026-08-06

---

# Purpose

This document records the repository-verified inventory of the semantic-history pipeline.

It documents current implementation behavior and does not propose future behavior.

---

# Scope

Question investigated:

> What semantic history exists today, where does it originate, how does it flow through the runtime, and which component owns each stage?

This investigation excludes:

- semantic ranking design
- prompt redesign
- retrieval optimization
- token-budget redesign
- behavioral redesign

---

# Repository Findings

## Overall Structure

The repository implements semantic-history processing through successive persisted records and runtime read models rather than through one semantic-history object.

Each inspected stage performs a distinct transformation or classification before passing its result downstream.

---

## Verified Pipeline

Conversation Turns
→ Conversation History Context
→ Interpretation Context
→ Authority Evaluation
→ Contamination Evaluation
→ History Selection
→ Conversation Context Runtime
→ selectedHistory
→ Ollama
→ durableInterpretation
→ Interpretation Evidence Ledger
→ Living Draft

---

# Artifact Inventory

## Conversation Turns

Owner:
Conversation persistence runtime

Lifetime:
Persisted

Verified purpose:
Stores project-scoped and conversation-scoped user messages, assistant replies, interpretation-entry lineage, project-context evidence traces, and creation timestamps.

---

## Conversation History Context

Owner:
Conversation History Context Runtime

Lifetime:
Runtime read model

Verified purpose:
Transforms persisted conversation turns into the history representation consumed by later interpretation stages while preserving content, order, and lineage.

---

## Interpretation Lifecycle Entries

Owner:
Interpretation Lifecycle Provider

Source:
Interpretation Evidence Ledger entries associated with the retrieved conversation turns

Lifetime:
Runtime read model

Verified purpose:
Provides the supersession status associated with each retrieved interpretation entry.

---

## Interpretation Context

Owner:
Interpretation Context Runtime

Lifetime:
Runtime read model

Verified purpose:
Associates each history turn with its interpretation-entry identifier, source-turn identifier, supersession status, and contamination status.

---

## Authority Evaluation

Owner:
History Authority Evaluator

Lifetime:
Runtime read model

Verified purpose:
Classifies interpretations as authority eligible, superseded, or unresolved.

The evaluator does not perform ranking.

---

## Contamination Evaluation

Owner:
History Contamination Evaluator

Lifetime:
Runtime read model

Verified purpose:
Classifies evaluated interpretations according to contamination state.

The evaluator does not perform ranking.

---

## History Selection

Owner:
History Selection Runtime

Lifetime:
Runtime read model

Verified purpose:
Filters conversation history using authority and contamination evaluations.

No conversation-history scoring, weighting, embedding retrieval, similarity comparison, or semantic ranking was identified during this investigation.

---

## Conversation Context Runtime

Owner:
Conversation Context Runtime

Lifetime:
Runtime composite read model

Verified purpose:
Composes conversation history, interpretation context, authority evaluations, contamination evaluations, selected history, project-context excerpts, and project-context warnings.

---

## selectedHistory

Producer:
Conversation Context Runtime

Consumer:
Conversation Workflow

Lifetime:
Runtime

Verified purpose:
Provides the filtered conversation-history collection supplied to the workflow.

---

## reply

Producer:
Ollama

Lifetime:
Runtime until conversation persistence

Verified purpose:
Provides the assistant response returned to the user.

---

## durableInterpretation

Producer:
Ollama

Lifetime:
Runtime until Interpretation Evidence Ledger persistence

Verified purpose:
Provides the durable interpretation generated for the current conversation turn.

---

## Interpretation Evidence Ledger

Persistence owner:
Conversation Workflow

Lifetime:
Persisted

Verified purpose:
Persists the durable interpretation and associated metadata.

---

## Living Draft

Owner:
Living Draft Runtime

Lifetime:
Persisted

Verified purpose:
Produces a synthesized representation derived from Interpretation Evidence Ledger entries.

---

# Conversation-History Retrieval

The production workflow retrieves conversation turns through:

listMatildaConversationTurns(projectId, 20, conversationId)

Verified behavior:

- scoped by project
- scoped by conversation
- validates explicit conversation ownership
- retrieval limit bounded between 1 and 100
- production requests 20 turns
- newest bounded window selected first
- bounded window reordered chronologically before semantic processing
- project-context evidence traces restored for each returned turn

Observed retrieval flow:

All persisted conversation turns
→ newest bounded window
→ chronological ordering
→ semantic-history pipeline

Within the retrieved window, no relevance scoring or semantic ranking was identified.

---

# Project-Context Retrieval

Project-context retrieval is implemented separately from conversation-history retrieval.

Verified behavior includes:

- query-term extraction
- stop-word removal
- bounded query terms
- repository-path filtering
- scored candidate generation
- ranked candidate ordering
- separate runtime and documentation candidate groups
- bounded excerpt selection
- provenance tracking
- candidate-evidence authority marking

The repository currently applies scored retrieval to project-context evidence and eligibility filtering to conversation history.

---

# Verified Ownership Boundaries

Conversation persistence owns conversation-turn storage and retrieval.

The Interpretation Lifecycle Provider supplies lifecycle entries.

The Conversation Context Runtime composes runtime semantic context.

Authority and Contamination Evaluators classify interpretations without persisting their results.

History Selection Runtime filters retrieved conversation history.

The Conversation Workflow consumes selectedHistory, performs one Ollama invocation, persists one Interpretation Evidence Ledger entry, and continues downstream processing.

Ollama produces reply and durableInterpretation.

Living Draft Runtime derives Living Draft state from persisted Interpretation Evidence Ledger entries.

---

# Persisted vs Runtime State

Persisted:

- conversation turns
- assistant replies
- interpretation-entry lineage
- project-context evidence traces
- Interpretation Evidence Ledger entries
- Living Draft state

Runtime-derived:

- conversation history context
- interpretation lifecycle entries
- interpretation context
- authority evaluations
- contamination evaluations
- selectedHistory
- conversation context
- project-context candidate scoring
- ranked project-context candidates

No evidence was found that authority evaluations, contamination evaluations, selectedHistory, or project-context rankings are independently persisted.

---

# Sub-corridor Findings

This investigation verified:

- semantic-history artifact inventory
- producer and consumer ownership
- persisted versus runtime responsibilities
- conversation retrieval behavior
- authority evaluation behavior
- contamination evaluation behavior
- history-selection behavior
- selectedHistory workflow consumption
- structured Ollama response ownership
- Interpretation Evidence Ledger persistence ownership
- Living Draft derivation
- project-context retrieval behavior
- no additional semantic-history selection path within the investigated repository scope

---

# Deferred Questions

Deferred to later sub-corridors:

- selection objectives
- semantic ranking
- token-budget behavior
- behavioral validation
- repository implementation readiness

---

# Scope Boundary

This document records repository-observed behavior only.

It does not conclude that:

- current behavior is sufficient,
- semantic ranking is required,
- retrieval systems should converge,
- the current retrieval window is optimal,
- behavioral validation is complete,
- implementation work is authorized.

