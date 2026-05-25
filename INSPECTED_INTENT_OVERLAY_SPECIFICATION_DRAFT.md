
# Inspected Intent Overlay Specification Draft

Phase: 739

Classification: GOVERNANCE-ONLY / SANDBOX-ONLY / NON-EXECUTING

## Purpose

Define deterministic overlay composition structures for inspected-intent visualization inside sandbox-only payload inspection environments.

This specification exists for:

- inspected-intent visualization planning

- semantic inspection overlays

- renderer-safe sandbox composition

- deterministic overlay validation

This specification is NOT:

- Preview authority

- renderer authority

- runtime authority

- execution infrastructure

- orchestration infrastructure

---

# Overlay System Goals

The overlay system must:

- remain deterministic

- remain inspection-oriented

- remain renderer-safe

- remain sandbox-only

- remain non-authoritative

The overlay system must NOT:

- mutate Preview

- mutate runtime

- mutate renderer routing

- execute worker actions

- create hidden orchestration pathways

---

# Top-Level Overlay Structure

{

  "overlay_id": "string",

  "overlay_type": "string",

  "target_scope": "string",

  "overlay_components": [],

  "inspection_metadata": {},

  "sandbox_only": true

}

---

# Allowed Overlay Types

Allowed overlay types:

- semantic_trace_overlay

- confidence_overlay

- lifecycle_overlay

- artifact_origin_overlay

- inspection_warning_overlay

Undefined overlay types must fail validation.

---

# Allowed Target Scopes

Allowed target scopes:

- payload

- component

- annotation

- semantic_mapping

- inspection_panel

No target scope may:

- mutate runtime state

- alter Preview authority

- alter renderer authority

---

# Overlay Component Structure

{

  "component_id": "string",

  "component_type": "string",

  "display_mode": "string",

  "overlay_payload": {}

}

Allowed display modes:

- inline

- expandable

- floating_panel

- hover

---

# Semantic Trace Overlay Example

{

  "overlay_id": "overlay-trace-001",

  "overlay_type": "semantic_trace_overlay",

  "target_scope": "component",

  "overlay_components": [

    {

      "component_id": "trace-component-001",

      "component_type": "trace_card",

      "display_mode": "expandable",

      "overlay_payload": {

        "semantic_role": "artifact_summary",

        "mapping_reference": "semantic-component-registry.v1",

        "confidence_state": "stable"

      }

    }

  ],

  "inspection_metadata": {

    "generated_by": "sandbox-inspection-layer",

    "runtime_authority": false,

    "preview_authority": false

  },

  "sandbox_only": true

}

---

# Validation Rules

Overlay validation must fail if:

- overlay_id missing

- overlay_type missing

- target_scope missing

- sandbox_only not true

- runtime authority requested

- Preview authority requested

- renderer authority requested

- execution mutation implied

---

# Locked Invariants

This overlay system:

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

