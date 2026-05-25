
# Semantic Component Mapping Registry Draft

Phase: 739

Classification: GOVERNANCE-ONLY / SANDBOX-ONLY / NON-EXECUTING

## Purpose

Define deterministic mappings between semantic intent classifications and sandbox-safe visual component types.

This registry is:

- inspection-only

- renderer-safe

- Preview-safe

- governance-only

This registry is NOT:

- runtime authority

- renderer authority

- execution authority

- worker orchestration

- automatic UI mutation

---

# Mapping Registry Structure

{

  "mapping_version": "semantic-component-registry.v1",

  "mappings": []

}

---

# Mapping Definition Structure

{

  "semantic_intent": "string",

  "semantic_role": "string",

  "recommended_component": "string",

  "allowed_annotations": [],

  "sandbox_only": true

}

---

# Initial Deterministic Mappings

## Informational Summary

{

  "semantic_intent": "summarize",

  "semantic_role": "artifact_summary",

  "recommended_component": "artifact_summary",

  "allowed_annotations": [

    "semantic_trace",

    "artifact_origin"

  ],

  "sandbox_only": true

}

---

## Task Prioritization

{

  "semantic_intent": "prioritize",

  "semantic_role": "task_priority",

  "recommended_component": "checklist",

  "allowed_annotations": [

    "confidence_indicator",

    "inspection_warning"

  ],

  "sandbox_only": true

}

---

## Timeline Visualization

{

  "semantic_intent": "timeline",

  "semantic_role": "chronology",

  "recommended_component": "timeline",

  "allowed_annotations": [

    "semantic_trace",

    "artifact_origin"

  ],

  "sandbox_only": true

}

---

## Risk Detection

{

  "semantic_intent": "risk_detection",

  "semantic_role": "warning_surface",

  "recommended_component": "warning_banner",

  "allowed_annotations": [

    "inspection_warning",

    "confidence_indicator"

  ],

  "sandbox_only": true

}

---

# Validation Constraints

Registry validation must fail if:

- semantic_intent missing

- semantic_role missing

- recommended_component missing

- runtime authority requested

- Preview authority requested

- execution mutation implied

---

# Locked Invariants

This registry:

- cannot mutate Preview

- cannot mutate renderer

- cannot trigger workers

- cannot execute runtime actions

- cannot bypass Matilda

- cannot bypass reconciliation

- cannot bypass rollback discipline

- cannot escalate semantic infrastructure into execution authority

