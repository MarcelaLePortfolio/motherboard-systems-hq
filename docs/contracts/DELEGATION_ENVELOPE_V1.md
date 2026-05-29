
# Delegation Envelope v1

## Purpose

The Delegation Envelope is the authoritative execution contract passed from Matilda to Cade.

Delegation is a bounded authorization event.

Cade may proceed only when the delegation envelope is valid, evidence-backed, scoped, bounded, and fully inside the defined constraints.

Delegation does not authorize scope expansion, intent creation, or inference-based execution.

If intent evidence is insufficient, Cade must pause and return for clarification.

---

# Core Principle

Matilda preserves and interprets established user intent.

Matilda does not create intent.

Cade performs bounded execution only inside evidence-backed delegation scope.

Governance constrains both.

---

# Execution Model

Flow:

1. User collaborates with Matilda

2. Matilda produces delegation envelope

3. User delegates task to Cade

4. Delegation becomes bounded execution authorization only if intent evidence, scope, validation, and rollback requirements are complete

5. Cade executes within delegated scope or pauses if intent evidence is insufficient

6. Audit + reconciliation recorded

---

# Required Envelope Fields

## Identity

- delegation_id

- session_id

- project_id

- project_root

- issued_by

- issued_at

---

## Objective

- task_title

- task_summary

- expected_outcome

- intent_evidence

---

## Execution Scope

Defines what Cade MAY mutate.

Examples:

- app/dashboard/*

- scripts/runtime/*

- docs/contracts/*

Scope must be explicit.

---

## Forbidden Scope

Defines protected surfaces Cade may NOT mutate.

Examples:

- secrets/

- .env

- disaster_recovery/

- protected governance contracts

Forbidden scope overrides execution scope.

---

## Allowed Operations

Examples:

- create_file

- modify_file

- delete_file

- git_commit

- run_tests

- deploy_preview

Operations not explicitly allowed are denied.

---

## Validation Requirements

Defines required verification before completion.

Examples:

- npm run lint

- npm run build

- integration smoke tests

- screenshot verification

Validation failures block completion.

---

## Rollback Expectations

Defines rollback strategy before execution begins.

Examples:

- git revert

- restore checkpoint

- restore snapshot

- manual rollback notes

Rollback pathway must exist before mutation.

---

## Audit Requirements

Execution must record:

- affected files

- commands executed

- validation results

- git commit hashes

- execution start/end timestamps

- rollback references

- failure state if applicable

---

# Governance Rules

## Cade MAY

- mutate files within allowed scope only when intent evidence is sufficient

- run approved commands

- create commits

- execute validation

- produce reconciliation summaries

---

## Cade MAY NOT

- exceed scope boundaries

- create intent

- infer missing intent

- treat ambiguity as authorization

- self-expand authority

- mutate forbidden surfaces

- silently skip validation

- bypass rollback requirements

- reuse old delegation envelopes

- reinterpret ambiguous instructions

- proceed when intent evidence is insufficient

---

# Delegation Validity Rules

Delegation must be:

- explicit

- scoped

- bounded

- project-specific

- session-specific

Delegation becomes invalid if:

- intent evidence is insufficient

- scope changes

- project changes

- governance changes

- execution ambiguity appears

- rollback path becomes unavailable

---

# Project Selection Model

Selected project defines execution root.

All mutation must remain inside selected project boundary.

Examples:

- client repository

- sandbox repository

- Motherboard Systems repository

Project selection does NOT change governance requirements.

Higher-risk projects may enforce stricter recovery corridors.

---

# Motherboard Systems Classification

Motherboard Systems is classified as:

CRITICAL INFRASTRUCTURE PROJECT SURFACE

Additional governance may require:

- checkpoint-first execution

- mandatory rollback capture

- protected surface restrictions

- sandbox-first verification

- elevated reconciliation detail

This does not create a separate execution architecture.

It is the same delegation system operating under stricter recovery governance.

---

# Architectural Principle

The system does not use autonomous self-modification.

The system uses governed delegated engineering.

