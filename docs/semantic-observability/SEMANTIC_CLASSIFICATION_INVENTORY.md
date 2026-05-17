
# Semantic Classification Inventory

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Purpose

Document observed and currently supported semantic classifications without introducing renderer authority, execution coupling, orchestration coupling, or persistence mutation.

## Phase 728 Status

This inventory is aligned with the canonical Phase 728 semantic surface.

Canonical artifact-scoped fields:

- artifact.semantic_artifact

- artifact.semantic_artifact_schema

- artifact.semantic_artifact_validated

The semantic substrate remains:

- additive

- observational

- runtime-attached

- artifact-scoped

- renderer-independent

- non-authoritative

## semantic_intent Inventory

### inform

Observed meaning:

Informational artifact output.

Observed characteristics:

- markdown-oriented artifact output

- fallback_markdown present

- visual_artifact generally false

- explanation-oriented execution payloads

Authority level:

Observational only.

---

### visualize

Observed meaning:

Visual-capable artifact output.

Observed characteristics:

- visual_artifact true

- visual composition metadata may be present

- visual-only Preview rendering may be eligible

- markdown fallback preserved internally

Authority level:

Advisory and observational only.

---

### summarize

Observed meaning:

Summary-oriented artifact output.

Observed characteristics:

- classification triggered by summary or recap language

- fallback_markdown present

- no renderer authority implied

Authority level:

Observational only.

---

### plan

Observed meaning:

Planning, roadmap, or strategy-oriented artifact output.

Observed characteristics:

- classification triggered by plan, roadmap, or strategy language

- fallback_markdown present

- no orchestration authority implied

Authority level:

Observational only.

---

### compare

Observed meaning:

Comparison-oriented artifact output.

Observed characteristics:

- classification triggered by compare, versus, or vs. language

- fallback_markdown present

- no execution branching implied

Authority level:

Observational only.

---

### execute

Observed meaning:

Execution-language artifact classification.

Observed characteristics:

- classification triggered by execute, run, deploy, or build language

- semantic classification does not grant execution authority

- no task routing mutation implied

Authority level:

Observational only.

## artifact_kind Inventory

### markdown

Observed meaning:

Default artifact classification.

Authority level:

Observational only.

---

### launch_card

Observed meaning:

Visual card-oriented artifact classification.

Observed characteristics:

- visual_artifact usually true

- visual composition metadata may be present

Authority level:

Observational only.

---

### visual

Observed meaning:

General visual artifact classification.

Observed characteristics:

- visual_artifact true

- visual-only Preview rendering may be eligible

Authority level:

Advisory and observational only.

---

### report

Observed meaning:

Report-oriented artifact classification.

Authority level:

Observational only.

---

### plan

Observed meaning:

Plan-oriented artifact classification.

Authority level:

Observational only.

---

### checklist

Observed meaning:

Checklist or steps-oriented artifact classification.

Authority level:

Observational only.

## visual_artifact Inventory

### false

Observed meaning:

Artifact treated as non-visual semantic output.

Observed characteristics:

- markdown persistence preserved

- semantic readability oriented

- no embedded visual HTML required

Authority level:

Advisory only.

---

### true

Observed meaning:

Artifact classified as visual-capable output.

Observed characteristics:

- visual delegation workflow may be active

- visual-only Preview rendering may be eligible

- markdown fallback preserved internally

- visual_composition may be present

Authority level:

Advisory only.

## Optional visual_composition Inventory

Observed status:

Optional metadata for visual-capable artifacts.

Purpose:

Describes visual composition characteristics without granting renderer authority.

Authority level:

Observational only.

## Current Schema Inventory

### semantic-artifact.v1

Observed status:

Stable through Phase 728 semantic consistency alignment.

Observed properties:

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

- retry coupling

- SSE mutation

- task route mutation

- persistence schema mutation

## Future Safe Expansion Areas

Allowed:

- documentation

- inspection tooling

- observational analytics

- metadata consistency tracking

- classification audit reports

- historical lineage documentation

Forbidden:

- renderer-authoritative semantics

- orchestration coupling

- semantic execution branching

- semantic retry influence

- semantic persistence expansion

