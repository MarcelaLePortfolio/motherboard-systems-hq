
# Matilda Package Contract

Status: CANDIDATE ARCHITECTURAL FINDING

## Purpose

The Matilda Package is the canonical interpretation artifact produced by Matilda.

The package exists to preserve Matilda's understanding of established user intent before delegation occurs.

The package allows the user to review the proposed work package before it enters the delegation system.

The package is not an execution artifact.

The package is not an authorization artifact.

The package is not an execution envelope.

---

## Architectural Position

Current lifecycle:

User Intent

↓

Matilda Package

↓

User Delegation

↓

Execution Envelope

↓

Preview

↓

Preview Approval

↓

Execution

↓

Reconciliation

---

## Core Principle

Matilda interprets intent.

Matilda does not create intent.

The package preserves Matilda's interpretation.

The package does not authorize execution.

---

## Authority Model

### User

Authority:

- Intent Authority

User remains the sole source of intent authority.

---

### Matilda

Authority:

- Interpretation Authority

- Governance Authority

- Delegation Authority

Matilda may:

- interpret intent

- refine intent

- clarify intent

- preserve intent

Matilda may not:

- create intent

- invent intent

- expand intent without authorization

- replace missing intent with inference

---

### Cade

Authority:

- Execution Authority

- Validation Authority

- Reconciliation Authority

Cade receives delegated work only after package delegation and envelope generation.

---

## Package Definition

A Matilda Package is a governed interpretation artifact.

The package describes:

- what work is proposed

- why the work is proposed

- what artifacts are expected

- what scope boundaries apply

- what outcomes are expected

The package should contain sufficient detail for downstream delegation without requiring Cade to invent missing requirements.

---

## Required Package Contents

### Intent Summary

Preserves the interpreted user objective.

### Proposed Work

Defines the work Matilda believes should occur.

### Proposed Artifacts

Defines the expected artifacts to be created, modified, analyzed, or reconciled.

### Scope Boundary

Defines:

- in-scope work

- out-of-scope work

### Constraints

Defines governing restrictions and limitations.

### Expected Outcome

Defines the intended result if the work succeeds.

### Delegation Target

Defines the intended recipient of delegation.

Examples:

- Cade

- Effie

- Atlas

---

## Prohibited Package Contents

A Matilda Package must not contain:

- execution authorization

- runtime authorization

- shell authorization

- autonomous execution authorization

- deployment authorization

The package is an interpretation artifact only.

---

## Delegation Relationship

The package itself carries no execution authority.

Interpretation Authorization occurs when the user delegates the package.

The act of delegation represents acceptance of Matilda's interpretation.

The package does not contain approval state.

The package does not contain approval controls.

The package does not contain workflow buttons.

Authorization is represented by user delegation behavior.

---

## Envelope Relationship

The package precedes the execution envelope.

The package is not a substitute for the execution envelope.

The execution envelope remains the canonical delegation artifact.

Approved interpretation may be transformed into a governed execution envelope.

The envelope inherits approved interpretation details from the package.

---

## Preview Relationship

The package is not a preview.

The package answers:

"What should happen?"

The preview answers:

"What will happen if executed?"

These are distinct governance checkpoints.

---

## Execution Relationship

Package delegation does not authorize execution.

Execution authorization occurs later through preview approval.

Interpretation Authorization and Execution Authorization are distinct events.

---

## Architectural Finding

The Matilda Package appears to be the primary artifact produced by Matilda.

The execution envelope appears to be a downstream governance artifact derived from an approved package.

This preserves separation between:

- interpretation

- delegation

- execution

while maintaining existing envelope governance architecture.

---

## Scope Boundary

This contract defines governance architecture only.

This contract does not authorize:

- runtime implementation

- orchestration implementation

- state machine implementation

- UI implementation

- execution implementation

Implementation remains out of scope until separately authorized.

