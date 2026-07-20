# 06 — Core Operator Surfaces

## Purpose

This document defines the minimum required operator-facing surfaces for Motherboard Systems HQ.

These surfaces are architectural requirements.

Their visual presentation, routing, and implementation remain open, but their functional presence is required for governed operation.

---

## Matilda Chat

Matilda Chat is the primary interface through which operators communicate intent to the system.

It is responsible for supporting:

- Intent capture.
- Clarification.
- Interpretation.
- Recommendation.
- Delegation preparation.
- Explanation of uncertainty.
- Presentation of proposed governed work.
- Communication of outcomes and required follow-up.

Matilda Chat preserves the distinction between:

- User intent.
- Interpretation.
- Recommendation.
- Authorization.
- Delegation.
- Execution.

Matilda does not execute work directly.

---

## Packages Inbox

The Packages Inbox is the primary authorization surface for governed work packages.

Its purpose is to present proposed work that requires user review before authoritative execution may proceed.

The inbox should support packages in states including:

- Pending review.
- Pending authorization.
- Revision requested.
- Approved.
- Rejected.
- Executing.
- Completed.
- Recovery required.
- Reconciliation required.
- Outcome review required.

Each package should expose sufficient context for an informed authorization decision, including, where applicable:

- User intent.
- Interpretation.
- Proposed delegation.
- Target actor.
- Requested scope.
- Constraints.
- Requested authority.
- Risks.
- Validation requirements.
- Recovery expectations.
- Current lifecycle state.

The backend remains authoritative for authorization state.

The frontend communicates that state accurately.

---

## Authorization Flow

Governed execution follows this conceptual flow:

1. The operator expresses intent through Matilda Chat.
2. Matilda interprets the intent and prepares a governed work package.
3. The proposed package appears in the Packages Inbox.
4. The operator reviews the package.
5. The operator approves, revises, or rejects the proposal.
6. The backend validates and records the authoritative decision.
7. Authorized execution proceeds.
8. Progress, recovery, reconciliation, and outcome review remain observable.

Individual workflows may vary, but governed execution must preserve the distinction between interpretation, authorization, and execution.

---

## Relationship to the Lifecycle

Matilda Chat and the Packages Inbox are not individual lifecycle stages.

They are operator-facing surfaces through which multiple lifecycle stages become visible and actionable.

They provide the primary operator experience for interacting with governed work throughout its lifecycle.

---

## Architectural Requirement

The frontend architecture must provide functional equivalents of:

- Matilda Chat
- Packages Inbox

These are required operator capabilities.

Their implementation may evolve, but their functional role within the governed workflow must be preserved.
