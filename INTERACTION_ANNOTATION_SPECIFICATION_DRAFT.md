
# Interaction Annotation Specification Draft

Phase: 739

Classification: GOVERNANCE-ONLY / SANDBOX-ONLY / NON-EXECUTING

## Purpose

Define deterministic interaction annotation structures for sandbox-only inspected-intent visualization.

This specification exists exclusively for:

- sandbox interaction planning

- semantic trace visualization planning

- inspection metadata overlays

- deterministic annotation validation

This specification is NOT:

- runtime interaction authority

- Preview authority

- renderer mutation authority

- execution infrastructure

---

# Annotation System Goals

The annotation layer must:

- remain deterministic

- remain renderer-safe

- remain sandbox-only

- remain inspection-oriented

- remain non-authoritative

The annotation layer must NOT:

- mutate runtime state

- mutate Preview state

- trigger workers

- trigger execution

- create hidden orchestration pathways

---

# Top-Level Annotation Structure

{

  "annotation_id": "string",

  "annotation_type": "string",

  "target_component_id": "string",

  "visibility_mode": "string",

  "annotation_payload": {},

  "sandbox_only": true

}

---

# Allowed Annotation Types

Allowed annotation types:

- semantic_trace

- artifact_origin

- confidence_indicator

- inspection_warning

- lifecycle_marker

- mapping_reference

Any undefined annotation type must fail validation.

---

# Visibility Modes

Allowed visibility modes:

- hover

- inline

- expandable

- inspection_panel

No visibility mode may:

- mutate component state

- execute runtime actions

- alter renderer authority

---

# Semantic Trace Annotation Example

{

  "annotation_id": "trace-001",

  "annotation_type": "semantic_trace",

  "target_component_id": "component-001",

  "visibility_mode": "expandable",

  "annotation_payload": {

    "source_intent": "summarize",

    "semantic_role": "artifact_summary",

    "mapping_reference": "semantic-component-registry.v1"

  },

  "sandbox_only": true

}

---

# Confidence Indicator Example

{

  "annotation_id": "confidence-001",

  "annotation_type": "confidence_indicator",

  "target_component_id": "component-002",

  "visibility_mode": "inline",

  "annotation_payload": {

    "confidence_score": 0.92,

    "classification_state": "stable"

  },

  "sandbox_only": true

}

---

# Validation Rules

Annotation validation must fail if:

- annotation_id missing

- annotation_type missing

- target_component_id missing

- visibility_mode missing

- sandbox_only not true

- runtime authority requested

- Preview authority requested

- execution mutation implied

---

# Locked Invariants

This annotation system:

- cannot mutate Preview

- cannot mutate runtime

- cannot mutate renderer routing

- cannot trigger workers

- cannot orchestrate Docker

- cannot orchestrate PM2

- cannot execute filesystem mutations

- cannot bypass Matilda approval

- cannot bypass reconciliation

- cannot bypass rollback discipline

- cannot escalate into execution authority

