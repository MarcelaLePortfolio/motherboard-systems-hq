# UI Shell Direction

## Status

This document describes the current experimental direction for the frontend shell.

It is not an architectural invariant.

It should be evaluated against the existing backend contracts, reusable frontend modules, and repository constraints before implementation begins.

## Purpose

Motherboard Systems HQ should use a stable application shell that reduces frontend complexity while preserving the system's governed operating model.

The shell should use familiar interaction grammar without copying the expressive identity of another product.

Familiar structure is intended to reduce learning cost.

Product differentiation remains in the governance lifecycle, authorization model, agent organization, backend authority, recovery, reconciliation, and outcome review.

## Proposed Shell

The current shell direction consists of:

- A persistent sidebar
- One primary workspace
- A shared contextual interaction layer for smaller activities

The application shell remains stable while the primary workspace changes according to the operator's current focus.

## Default Workspace

The primary workspace initially presents Matilda.

Matilda is the operator's default interface for:

- Expressing intent
- Clarifying objectives
- Reviewing interpretations
- Receiving recommendations
- Preparing governed work
- Understanding uncertainty
- Moving into authorization

Matilda does not execute work directly.

The presence of conversational interaction must not imply that conversational text alone authorizes execution.

## Workspace Replacement

Activities that require substantial space should replace Matilda in the primary workspace.

Examples may include:

- Package review
- Delegation review
- Project inspection
- Atlas investigation
- Telemetry inspection
- Execution detail
- Recovery
- Reconciliation
- Outcome review

When the operator finishes or leaves another workspace, the prior Matilda conversation state should remain recoverable.

The exact routing, history, and state-preservation model remains unresolved.

## Contextual Interactions

Not every activity requires a full workspace.

Smaller, bounded interactions may use:

- Dialogs
- Drawers
- Popovers
- Inline expansions
- Confirmation surfaces

The presentation form should match the complexity and authority of the interaction.

A small confirmation may use a dialog.

A governed artifact containing scope, constraints, authority, risks, validation, and history should not be compressed into an undersized modal.

## Packages

Packages remain a first-class operator capability and the primary authorization surface.

The sidebar or another persistent shell element must provide a reliable way to:

- Discover packages requiring attention
- Open a package
- Reopen a package
- Identify its current lifecycle state
- Return to its originating context when available

Package authorization must remain explicit.

Approval, revision, rejection, and other governed decisions must be represented through backend-authoritative state and contracts.

## Sidebar

The sidebar provides persistent orientation and access to important operator capabilities.

Its exact contents, hierarchy, ordering, and grouping are not yet decided.

Potential contents may include:

- Matilda
- Packages
- Projects
- Attention
- Agents
- Recent contexts
- System capabilities

These are candidates, not confirmed navigation requirements.

Claude should not finalize the sidebar information architecture unless explicitly asked.

## Backend Authority

The frontend remains a projection of backend truth.

The shell must not:

- Manufacture lifecycle state
- Infer authority
- Invent missing contracts
- Treat absent reference files as evidence that a capability does not exist
- Collapse interpretation, authorization, and execution into one UI action

Every workspace should render from authoritative backend data where such contracts exist.

Missing contracts must remain visibly unresolved.

## Design Principle

The operator should feel that they remain inside one coherent operating environment.

The shell stays stable.

The operator's focus changes.

Navigation should change context rather than feel like movement between unrelated applications.

## Evaluation Requirement

Before implementation, evaluate:

1. Whether this shell reduces frontend complexity
2. Whether it aligns with backend-authoritative rendering
3. Which supplied frontend modules can be reused
4. Which modules are coupled to the previous dashboard model
5. What state-preservation risks it introduces
6. What routing and deep-linking requirements it creates
7. Whether Packages can remain reliably discoverable and reopenable
8. Whether the shell preserves clear governance boundaries
9. What additional repository evidence is required

## Implementation Status

Implementation remains paused.

Do not produce routes, React components, styling, or mockups solely from this document.

First provide an evidence-based architectural evaluation of this direction.
