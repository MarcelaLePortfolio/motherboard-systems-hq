# Frontend Implementation Boundaries

## Purpose

This document defines the architectural boundaries for evaluating and eventually implementing the frontend.

It is intended to prevent implementation drift, architectural invention, and frontend behavior that conflicts with established backend authority.

## Current Status

Implementation remains paused.

The current objective is architectural evaluation rather than code generation.

Do not generate React components, routes, layouts, styling, or implementation plans unless explicitly requested.

## Backend Authority

The backend remains authoritative.

The frontend is responsible for presenting backend truth rather than creating it.

Do not:

- Invent backend state
- Manufacture lifecycle transitions
- Infer authority
- Simulate missing contracts
- Replace backend logic with frontend behavior

## Governance

Do not redesign:

- Governance
- Authorization
- Delegation
- Lifecycle
- Recovery
- Reconciliation
- Outcome review

These are architectural concerns that already exist independently of the frontend.

## Domain Model

Do not introduce new domain concepts solely to simplify the frontend.

Reuse existing architectural concepts whenever supported by evidence.

If a required concept appears to be missing:

- identify it
- explain why it appears necessary
- request clarification

Do not silently invent it.

## Repository Evidence

Treat the repository as authoritative evidence.

Do not conclude that a capability does not exist simply because it was not included in the handoff packet.

Instead distinguish between:

- confirmed
- unavailable
- unresolved

## Reuse

Prefer reuse over replacement.

Evaluate:

- existing reusable modules
- shared frontend utilities
- telemetry components
- operator guidance components
- existing backend contracts

before recommending new implementation.

## State Management

Preserve operator context whenever practical.

Workspace changes should avoid unnecessary loss of:

- conversation state
- package context
- investigation context
- operator orientation

State restoration requirements should be explicitly identified rather than assumed.

## Evaluation Expectations

When evaluating the frontend, distinguish between:

Confirmed findings

Reasonable inferences

Architectural proposals

Unknowns requiring additional repository evidence

Do not merge these categories.

## Additional Repository Requests

Request only the minimum additional repository context necessary.

Explain:

- why it is needed
- what uncertainty it resolves
- why existing evidence is insufficient

## Success

A successful evaluation should:

- reduce implementation risk
- identify hidden coupling
- preserve backend authority
- preserve governance
- minimize unnecessary frontend complexity
- avoid speculative redesign
