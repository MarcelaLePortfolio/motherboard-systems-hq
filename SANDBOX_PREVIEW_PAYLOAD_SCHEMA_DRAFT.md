
# Sandbox Preview Payload Schema Draft

Phase: 739

Classification: SANDBOX-ONLY / NON-AUTHORITATIVE / GOVERNANCE-ONLY

## Purpose

Define a deterministic payload structure for renderer-safe sandbox visual composition.

This schema is NOT:

- runtime authority

- Preview authority

- execution authority

- renderer replacement

- semantic-preview authority

This schema exists solely for:

- deterministic payload inspection

- sandbox visualization planning

- semantic-to-component mapping analysis

---

# Top-Level Payload Structure

{

  "schema_version": "sandbox-preview-payload.v1",

  "artifact_id": "string",

  "intent_summary": "string",

  "components": [],

  "interaction_annotations": [],

  "inspection_metadata": {},

  "validation_state": {}

}

---

# Component Definition

{

  "component_id": "string",

  "component_type": "string",

  "semantic_role": "string",

  "props": {},

  "children": []

}

Allowed example component types:

- card

- checklist

- timeline

- insight_block

- warning_banner

- artifact_summary

---

# Interaction Annotation Structure

{

  "annotation_id": "string",

  "target_component_id": "string",

  "annotation_type": "string",

  "annotation_payload": {}

}

Allowed annotation types:

- hover_explanation

- semantic_trace

- confidence_indicator

- artifact_origin

- inspection_warning

---

# Inspection Metadata Structure

{

  "generated_at": "ISO_TIMESTAMP",

  "semantic_schema_version": "string",

  "sandbox_only": true,

  "runtime_authority": false,

  "preview_authority": false

}

---

# Validation Rules

Payload validation must fail if:

- schema_version missing

- component IDs duplicate

- semantic role undefined

- runtime authority requested

- Preview authority requested

- execution mutation requested

---

# Locked Invariants

This payload schema:

- cannot mutate runtime

- cannot mutate Preview

- cannot trigger workers

- cannot orchestrate Docker

- cannot orchestrate PM2

- cannot bypass Matilda approval

- cannot bypass rollback discipline

- cannot escalate into execution authority

