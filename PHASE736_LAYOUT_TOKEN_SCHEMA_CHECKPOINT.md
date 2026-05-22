
# Phase 736 Layout Token Schema Checkpoint

Status: stable sandbox schema evolution checkpoint

## Confirmed

- Render-native payload now supports explicit layout tokens.

- Nodes may reference layout tokens deterministically.

- Validator rejects unknown node layout token references.

- Sandbox renderer emits data-layout-token attributes.

- Inspection report records layout token count and references.

- Generated payload validates, renders, and inspects successfully.

- Live Preview renderer remains untouched.

## New Stable Commit

- d8493fab Add deterministic layout tokens to render-native sandbox payload

## Current Safe Next Target

Add a deterministic semantic input compiler that converts bounded semantic intent into sandbox render-native payload structures without touching live Preview.

