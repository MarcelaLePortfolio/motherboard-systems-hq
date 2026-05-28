
# Execution Implementation Next

## Current State

The canonical execution doctrine is now committed.

Authoritative documents now include:

- docs/contracts/DELEGATION_ENVELOPE_V1.md

- docs/contracts/CANONICAL_EXECUTION_DOCTRINE_V1.md

- AUTHORITATIVE_EXECUTION_CORRIDOR.txt

## Next Implementation Slice

Implement the minimum enforcement path for delegated execution.

Required components:

1. Delegation Envelope Schema

2. Envelope Validator

3. Project Root Resolver

4. Scope Boundary Checker

5. Forbidden Path Guard

6. Audit Event Writer

7. Reconciliation Summary Shape

## Implementation Rule

Do not implement autonomous execution loops.

Do not add background mutation.

Do not bypass explicit delegation.

Cade execution must remain bounded by the delegation envelope.

## Suggested Next File Targets

Likely implementation locations should be discovered before editing.

Search first for:

- task delegation route

- Cade task processor

- Matilda prompt generation

- task execution API

- project root handling

- audit/event writer

