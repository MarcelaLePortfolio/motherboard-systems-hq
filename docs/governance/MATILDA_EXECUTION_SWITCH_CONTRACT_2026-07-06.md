
# Matilda Execution Switch Contract

Date: 2026-07-06

## Purpose

Defines the single canonical state transition for Cade Execution eligibility.

## Switch Rule

Cade Execution is only allowed when:

- execution_authorized === true

- preview_confirmed === true

- execution_plan.status === "plan_review_ready"

- confirmation_result === "confirmed"

- no unresolved ambiguity exists

## Execution State (derived only)

- DISABLED

- ARMED

- READY

- EXECUTABLE (only valid entry point for Cade Execution)

## Boundary

This contract only evaluates eligibility and never triggers execution.

