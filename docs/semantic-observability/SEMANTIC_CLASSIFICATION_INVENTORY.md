
# Semantic Classification Inventory

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Purpose

Document observed semantic classifications without introducing renderer authority or execution coupling.

## Current Observed semantic_intent Values

### inform

Observed Meaning:

Informational artifact output.

Observed Characteristics:

- markdown artifact_kind

- fallback_markdown present

- visual_artifact often false

- explanation-oriented execution payloads

Authority Level:

Observational only.

## Current Observed visual_artifact Values

### false

Observed Meaning:

Artifact treated as non-visual semantic output.

Observed Characteristics:

- markdown persistence preserved

- semantic readability oriented

- no embedded visual HTML required

Authority Level:

Advisory only.

---

### true

Observed Meaning:

Artifact classified as visual-capable output.

Observed Characteristics:

- visual delegation workflow active

- visual-only Preview rendering eligible

- markdown fallback preserved internally

Authority Level:

Advisory only.

## Current Schema Inventory

### semantic-artifact.v1

Observed Status:

Stable during Phase 726–727 validation corridor.

Observed Properties:

- additive

- artifact-scoped

- renderer-independent

- rollback-safe

- non-authoritative

## Explicitly Forbidden

- semantic routing decisions

- semantic orchestration

- semantic execution control

- semantic-first rendering

- Preview reinterpretation

- artifact contract mutation

## Future Safe Expansion Areas

Allowed:

- documentation

- inspection tooling

- observational analytics

- metadata consistency tracking

Forbidden:

- renderer-authoritative semantics

- orchestration coupling

- semantic execution branching

