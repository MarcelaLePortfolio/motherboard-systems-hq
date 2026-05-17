
# Semantic Field Reference

## Corridor

READ-ONLY SEMANTIC OBSERVABILITY

## Live Artifact Fields Observed

### artifact.semantic_artifact

Observed structure:

{

  "artifact_kind": "markdown",

  "schema_version": "semantic-artifact.v1",

  "semantic_intent": "inform",

  "visual_artifact": false,

  "fallback_markdown": "..."

}

## Field Definitions

### artifact_kind

Current observed values:

- markdown

Purpose:

High-level artifact category.

Authority:

Observational only.

---

### schema_version

Current observed values:

- semantic-artifact.v1

Purpose:

Semantic payload schema tracking.

Authority:

Observational only.

---

### semantic_intent

Current observed values:

- inform

Purpose:

High-level semantic classification.

Authority:

Non-render-authoritative.

---

### visual_artifact

Current observed values:

- true

- false

Purpose:

Indicates whether worker classified artifact as visual.

Authority:

Advisory only.

---

### fallback_markdown

Purpose:

Preserved markdown persistence layer.

Authority:

Authoritative persistence fallback.

## Additional Live Fields

### artifact.semantic_artifact_schema

Observed:

semantic-artifact.v1

---

### artifact.semantic_artifact_validated

Observed:

true

Purpose:

Schema validation indicator.

Authority:

Validation-only.

## Explicitly Forbidden

- Semantic rendering authority

- Semantic orchestration

- Semantic execution control

- Preview contract mutation

- Retry coupling

- Worker mutation

