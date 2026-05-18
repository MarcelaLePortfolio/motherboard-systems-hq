
# Phase 729 Preview-Aware Classification Refinement

## Corridor

SEMANTIC CLASSIFICATION REFINEMENT (OBSERVATIONAL ONLY)

## Purpose

Correct semantic classification drift where advisory "preview-aware" planning language was incorrectly escalating artifacts into visual classifications.

## Problem

Prior Phase 728 classifier behavior treated the keyword:

- preview

as inherently visual.

This caused planning-oriented advisory requests such as:

- "Build a plan for preview-aware Matilda refinement"

to classify as:

- visual_artifact: true

- semantic_intent: visualize

despite being advisory planning semantics rather than explicit visual artifact requests.

## Refinement

Phase 729 introduced a guarded distinction:

### Advisory Preview-Awareness

Examples:

- preview-aware refinement

- preview-aware advisory planning

Observed classification:

- artifact_kind: plan

- semantic_intent: plan

- visual_artifact: false

### Explicit Visual Preview Requests

Examples:

- preview card

- visual preview

- preview render

- dashboard preview

Observed classification:

- visual_artifact: true

## Boundary Preservation

This refinement remains:

- additive

- keyword-bound

- renderer-independent

- non-authoritative

- artifact-scoped

- observational only

No changes were made to:

- renderer authority

- Preview routing

- execution contracts

- retry contracts

- persistence contracts

- SSE contracts

- orchestration behavior

## Result

Semantic consistency improved while preserving all existing authority boundaries and markdown fallback guarantees.

