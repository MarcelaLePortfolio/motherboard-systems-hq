
# Sandbox Mock Render Artifact Schema Draft

Phase: 740

Classification: GOVERNANCE-ONLY / SANDBOX-ONLY / NON-EXECUTING

## Purpose

Define deterministic mock render artifact structures for sandbox-only inspected composition rendering.

This schema exists exclusively for:

- sandbox visual structure generation

- deterministic mock rendering planning

- renderer-safe composition inspection

- governance-safe visual artifact definition

This schema is NOT:

- live renderer integration

- Preview authority

- runtime authority

- execution infrastructure

---

# Top-Level Mock Render Artifact Structure

{

  "artifact_version": "sandbox-mock-render.v1",

  "payload_reference": "string",

  "composition_graph_reference": "string",

  "render_nodes": [],

  "render_metadata": {},

  "sandbox_only": true

}

---

# Render Node Structure

{

  "render_node_id": "string",

  "component_id": "string",

  "render_type": "string",

  "layout_role": "string",

  "children": []

}

Allowed render types:

- card

- panel

- overlay

- annotation_surface

- inspection_trace

- timeline

- checklist

---

# Render Metadata Structure

{

  "inspection_mode": "string",

  "composition_strategy": "string",

  "sandbox_only": true,

  "runtime_authority": false,

  "preview_authority": false

}

Allowed inspection modes:

- static

- layered

- expandable

- trace_visualization

Allowed composition strategies:

- deterministic_linear

- deterministic_layered

- deterministic_grouped

---

# Validation Rules

Validation must fail if:

- artifact_version missing

- render_node_id missing

- component_id missing

- render_type undefined

- runtime authority requested

- Preview authority requested

- execution mutation implied

---

# Locked Invariants

This mock render schema:

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

