
# Phase 733 Aesthetic Theme Mapper Reassessment

## Decision

Do not hard-wire a fixed Artifact Garden aesthetic preset into the renderer.

## Reason

Hard-coding cream/blush/plum/sage styling before a general style interpretation contract exists would bias the preview renderer toward one user-requested presentation.

## Correct Direction

The preview layer should support request-scoped aesthetic intent, not permanent presentation assumptions.

## Revised Principle

Aesthetic composition must be:

- input-driven

- request-scoped

- optional

- reversible

- non-authoritative

- preview-only

## Safer Next Corridor

Define a neutral aesthetic intent contract first.

Example:

- styleIntent.background

- styleIntent.card

- styleIntent.text

- styleIntent.accent

- styleIntent.mood

- styleIntent.typography

- styleIntent.constraints

## Boundary

Do not mutate renderer defaults until style intent is explicitly present in the artifact payload or semantic envelope.

