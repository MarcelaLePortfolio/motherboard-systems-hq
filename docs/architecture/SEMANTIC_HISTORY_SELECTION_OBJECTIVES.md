# Semantic History Selection Objectives

## Behavioral Integration — Corridor 3

### Sub-corridor: Selection Objectives

Status: COMPLETE

Date: 2026-08-06

---

# Purpose

This document records the repository-observed objectives governing conversation-history selection within the Matilda Conversation Engine.

It documents current repository behavior only. It does not infer design intent or recommend future implementation.

---

# Scope

Question investigated:

> What objectives does the current conversation-history selector demonstrably achieve?

This investigation distinguishes:

- observed objectives
- selection mechanisms
- preservation guarantees
- implementation safeguards
- deferred behavior

This investigation excludes:

- semantic ranking design
- prompt redesign
- token-budget behavior
- behavioral validation
- implementation authorization

---

# Repository-Observed Objectives

## Project and Conversation Isolation

Conversation history is retrieved only from the requested project and conversation.

Observed objective:

> Prevent history from unrelated projects or conversations from entering the semantic pipeline.

---

## Bounded Conversation Window

The workflow retrieves a bounded recent conversation window before semantic evaluation.

Observed objective:

> Restrict semantic evaluation to a bounded recent conversation history.

Repository evidence establishes current behavior but does not establish that the current retrieval window is optimal.

---

## Authority-Based Admission

Interpretation lifecycle evaluation determines whether an interpretation is eligible.

Observed objective:

> Admit only history associated with authority-eligible interpretations.

---

## Contamination Exclusion

Authority-eligible interpretations undergo contamination evaluation before selection.

Observed objective:

> Exclude interpretations classified as contaminated.

---

## Fail-Closed Behavior

Unknown lifecycle state does not default to eligibility.

Observed objective:

> Prevent unresolved interpretation state from entering selected history by default.

---

# Preservation Objectives

The repository consistently preserves:

- conversation content
- chronological ordering
- conversation lineage
- interpretation lineage
- metadata
- input immutability

Observed objective:

> Preserve admitted history without altering its identity, ordering, or lineage.

---

# Selection Mechanism

The selector:

1. receives conversation history
2. receives authority evaluations
3. receives contamination evaluations
4. constructs the eligible source-turn set
5. filters conversation history by membership
6. returns surviving turns

No additional selection pass occurs after admission.

---

# Positive Preference Investigation

The active conversation-history path was inspected for evidence of:

- ranking
- weighting
- relevance scoring
- similarity
- embeddings
- prioritization
- importance
- salience
- tie-breaking
- post-admission truncation
- token-budget trimming
- candidate reordering

No evidence of positive preference was identified within the investigated conversation-history path.

Observed finding:

> Once a history turn satisfies the admission criteria, the selector preserves it rather than choosing among eligible candidates.

This finding applies only to the investigated repository scope.

---

# Objective Categories

## Admission Objectives

- project isolation
- conversation isolation
- bounded retrieval window
- authority eligibility
- contamination exclusion
- fail-closed handling of unresolved state

## Preservation Objectives

- preserve content
- preserve chronology
- preserve lineage
- preserve metadata
- avoid input mutation

## Positive Preference Objectives

No positive preference objective was identified within the investigated conversation-history path.

---

# Sub-corridor Findings

This investigation verified:

- admission-based conversation-history selection
- authority precedes contamination evaluation
- contamination precedes history selection
- preservation of eligible-turn ordering
- preservation of lineage
- preservation of metadata
- preservation of input immutability
- absence of post-admission ranking or preference
- separation between conversation-history eligibility filtering and project-context scored retrieval

---

# Deferred Questions

Deferred to subsequent sub-corridors:

- semantic ranking model
- token-budget behavior
- behavioral validation
- repository implementation readiness

---

# Scope Boundary

This document records repository-observed behavior only.

It does not conclude that:

- current behavior is sufficient
- semantic ranking is required
- semantic ranking is unnecessary
- the retrieval window is optimal
- project-context retrieval and conversation-history retrieval should converge
- implementation is authorized


---

# Semantic Ranking Model State

## Repository Finding

The active conversation-history pipeline does not implement a semantic ranking model.

Repository inspection found no evidence of:

- comparative ranking
- relevance scoring
- weighting
- prioritization
- semantic similarity
- embedding-based retrieval
- tie-breaking
- post-admission ordering

History selection currently consists of:

- bounded retrieval
- authority evaluation
- contamination evaluation
- eligibility filtering
- preservation of admitted history ordering

Once a history turn satisfies the admission criteria, no additional positive choice is made among eligible candidates.

---

## Intermediate Semantic Read Models

The Conversation Context Runtime composes and exposes the following runtime read models:

- interpretations
- evaluatedInterpretations
- contaminationEvaluations
- selectedHistory

Repository evidence demonstrates that these are first-class runtime read models which:

- are explicitly typed
- are composed sequentially
- are protected by repository tests
- preserve lineage and metadata
- support classification and admission

No repository evidence establishes that these intermediate models currently perform or own semantic ranking.

Likewise, no repository evidence establishes that they exist as future ranking extension points.

Such a characterization would be architectural inference rather than verified repository state.

---

## Ranking Responsibility

No ranking responsibility was identified within the active conversation-history path.

The current responsibility boundary is:

Conversation History
→ Authority Evaluation
→ Contamination Evaluation
→ Eligibility Filtering
→ selectedHistory

Project-context retrieval remains a separate repository subsystem with its own scored ranking behavior.


---

# Token Budget Behavior

## Repository Finding

Repository inspection identified a single repository-controlled history budget within the active conversation-history pipeline.

The production workflow retrieves:

listMatildaConversationTurns(projectId, 20, conversationId)

before semantic evaluation begins.

The retrieved conversation window then proceeds through:

- authority evaluation
- contamination evaluation
- eligibility filtering
- selectedHistory

The resulting selectedHistory is passed directly to the Conversation Workflow and serialized into the Ollama prompt.

No additional repository-controlled token budgeting was identified after history retrieval.

Repository inspection found no evidence of:

- prompt truncation
- history truncation after selection
- token-budget calculation
- max-token configuration
- context-window configuration
- post-selection history reduction

The repository therefore currently establishes a single effective conversation-history budget:

the bounded retrieval window.

---

## Retrieval Window

The production workflow currently requests:

20 conversation turns.

Repository inspection established the implementation.

Repository inspection did not establish why the value 20 was selected.

No repository evidence was identified that attributes the current retrieval window to:

- model context limitations
- token budgeting
- performance optimization
- prompt engineering
- architectural policy

The current retrieval window should therefore be treated as an observed implementation parameter rather than an architecturally justified constraint.

---

## Scope Boundary

This investigation establishes only repository-observed behavior.

It does not conclude that:

- the current retrieval window is optimal
- twenty turns is the correct retrieval budget
- the retrieval window should increase or decrease
- the retrieval window is driven by model token limits
- additional downstream context reduction is unnecessary
- implementation changes are authorized

