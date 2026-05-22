
# Semantic Preview Route Contract

Status: LOCKED

Corridor: READ-ONLY SEMANTIC INSPECTION

## Route

/api/tasks/:task_id/semantic-preview

## Purpose

Expose completed task semantic runtime state without changing Preview rendering behavior.

## Contract Type

Read-only semantic inspection transport.

This route is NOT:

- renderer transport

- Preview rendering input

- execution authority

- reconciliation authority

- artifact mutation path

- browser runtime dependency

## Required Response Fields

- ok

- corridor

- task_id

- status

- updated_at

- outcome_preview

- explanation_preview

- artifact

- artifacts

- guidance

- validation

## Required Corridor Value

read-only-semantic-inspection

## Required Validation Flags

- renderer_mutation_disabled: true

- preview_mutation_disabled: true

- execution_authority_disabled: true

- reconciliation_authority_disabled: true

## Boundary Rule

/artifact-preview remains the renderer-facing Preview transport.

/semantic-preview remains the semantic runtime inspection transport.

These routes must not be merged without explicit architectural approval and new runtime evidence.

## Stability Requirement

Future work may inspect, validate, summarize, or compare semantic-preview output.

Future work must not make Preview rendering depend on semantic-preview output unless a separate integration corridor is explicitly opened.

## Current Verified State

The route has been verified against task:

t_2b36c623-da32-498f-9436-8158a37ee7e3

Verified runtime behavior:

- returns JSON

- exposes outcome_preview

- exposes explanation_preview

- exposes artifact.semantic_artifact

- exposes semantic_artifact.schema_version

- exposes semantic_artifact.sections

- preserves artifact-preview as separate renderer corridor

