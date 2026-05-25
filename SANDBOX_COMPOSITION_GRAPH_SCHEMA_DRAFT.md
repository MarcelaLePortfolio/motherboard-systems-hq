
# Sandbox Composition Graph Schema Draft

Phase: 739

Classification: GOVERNANCE-ONLY / SANDBOX-ONLY / NON-EXECUTING

## Purpose

Define deterministic composition graph structures for sandbox-only inspected-intent visual composition planning.

This schema exists exclusively for:

- component relationship planning

- deterministic composition ordering

- overlay attachment modeling

- sandbox layout inspection

- renderer-safe structural visualization

This schema is NOT:

- runtime authority

- Preview authority

- renderer authority

- execution infrastructure

---

# Top-Level Composition Graph Structure

{

  "graph_version": "sandbox-composition-graph.v1",

  "root_nodes": [],

  "relationships": [],

  "layout_metadata": {},

  "sandbox_only": true

}

---

# Root Node Structure

{

  "node_id": "string",

  "component_id": "string",

  "children": [],

  "layout_role": "string"

}

Allowed layout roles:

- primary_panel

- secondary_panel

- overlay_surface

- annotation_surface

- inspection_panel

---

# Relationship Structure

{

  "relationship_id": "string",

  "source_node_id": "string",

  "target_node_id": "string",

  "relationship_type": "string"

}

Allowed relationship types:

- parent_child

- annotation_attachment

- overlay_attachment

- semantic_reference

- inspection_reference

---

# Layout Metadata Structure

{

  "composition_order": [],

  "inspection_mode": "string",

  "sandbox_only": true

}

Allowed inspection modes:

- static

- expandable

- layered

- inspection_trace

---

# Validation Rules

Validation must fail if:

- graph_version missing

- node_id missing

- component_id missing

- relationship_type undefined

- runtime authority requested

- Preview authority requested

- execution mutation implied

---

# Locked Invariants

This composition graph:

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

