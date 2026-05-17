
# Semantic Field Reference

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Phase 728 Status

This reference reflects the canonical Phase 728 semantic field surface.

The semantic substrate is:

- additive

- observational

- runtime-attached

- artifact-scoped

- renderer-independent

- non-authoritative

## Canonical Artifact Fields

### artifact.semantic_artifact

Canonical semantic payload field.

Observed structure:

{

  "schema_version": "semantic-artifact.v1",

  "artifact_kind": "markdown",

  "semantic_intent": "inform",

  "visual_artifact": false,

  "fallback_markdown": "..."

}

Visual artifacts may additionally include:

{

  "visual_composition": {

    "...": "..."

  }

}

Authority:

Observational only.

---

### artifact.semantic_artifact_schema

Canonical schema indicator.

Observed value:

- semantic-artifact.v1

Authority:

Schema tracking only.

---

### artifact.semantic_artifact_validated

Canonical validation indicator.

Observed value:

- true

Authority:

Validation-only.

## Semantic Payload Field Definitions

### schema_version

Current canonical value:

- semantic-artifact.v1

Purpose:

Identifies the semantic payload schema version.

Authority:

Observational only.

---

### artifact_kind

Observed values may include:

- markdown

- launch_card

- visual

- report

- plan

- checklist

Purpose:

High-level artifact classification.

Authority:

Observational only.

---

### semantic_intent

Observed values may include:

- inform

- visualize

- summarize

- plan

- compare

- execute

Purpose:

High-level semantic intent classification.

Authority:

Non-render-authoritative.

---

### visual_artifact

Observed values:

- true

- false

Purpose:

Indicates whether the worker classified the artifact as visual.

Authority:

Advisory and observational only.

---

### fallback_markdown

Purpose:

Preserves the markdown source used as the semantic fallback substrate.

Authority:

Persistence fallback only.

---

### visual_composition

Purpose:

Optional visual composition metadata for visual artifacts.

Authority:

Observational only.

## Defensive Devtools Aliases

Developer observability tooling may inspect these aliases defensively:

- artifact.semantic

- artifact.semantic_metadata

Current status:

No active runtime producer was found for these aliases during Phase 728 inspection.

Canonical producer field remains:

- artifact.semantic_artifact

## Explicitly Forbidden

- Semantic rendering authority

- Semantic orchestration

- Semantic execution control

- Preview contract mutation

- Retry coupling

- Worker behavior mutation

- Persistence schema mutation

- SSE mutation

- Task route mutation

