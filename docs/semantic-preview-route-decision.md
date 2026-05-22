
# Semantic Preview Route Decision

Status: APPROVED DIRECTION

Corridor: READ-ONLY RUNTIME ALIGNMENT

## Decision

Keep `/api/tasks/:task_id/artifact-preview` minimal and renderer-facing.

Introduce a separate read-only semantic inspection route rather than overloading the artifact Preview route.

## Reason

Runtime inspection confirmed that `/artifact-preview` currently functions as a lightweight renderer transport:

- resolves artifact file path

- reads markdown artifact content

- returns artifact metadata

- returns raw content

The frontend renderer bridge then reconstructs sections from markdown.

## Confirmed Boundary

The Preview route does not currently transport full semantic continuity data.

It does not return:

- full completed payload

- guidance

- semantic topology

- semantic lineage

- graph relations

- continuity reports

- reconciliation state

## Architectural Interpretation

This separation is healthy.

`/artifact-preview` should remain:

- renderer-facing

- content-oriented

- minimal

- stable

- low-coupling

Semantic inspection should move through a separate read-only route.

## Proposed Route

`/api/tasks/:task_id/semantic-preview`

## Route Purpose

Expose semantic runtime state for inspection without changing live Preview behavior.

The route may return:

- task_id

- artifact metadata

- completed payload summary

- semantic_artifact if present

- outcome_preview if present

- explanation_preview if present

- artifact semantic metadata if present

- lifecycle continuity notes

## Route Constraints

- read-only

- no renderer mutation

- no Preview mutation

- no browser injection

- no execution authority

- no reconciliation authority

- no artifact rewriting

- no markdown transformation

- no live Preview coupling

## Why Not Modify `/artifact-preview`

Overloading `/artifact-preview` would risk:

- renderer coupling

- transport ambiguity

- Preview instability

- semantic/runtime conflation

- accidental production behavior changes

## Next Safe Step

Add a read-only semantic-preview route that queries the same completed payload source as `/api/tasks`, but returns semantic inspection data separately from renderer transport.

