
# Phase 732 Queue Item 5 — Advisory Preview Overlay Mock Structures

## Classification

Observability-only.

Mock-structure-only.

Non-rendering.

Advisory-only.

## Objective

Define deterministic mock overlay structures for future Preview observability planning.

These structures are intentionally non-rendering and non-interactive.

No Preview integration or renderer integration is introduced.

## Proposed Overlay Structure

```json

{

  "overlayVersion": "phase732-preview-overlay-v1",

  "classification": "observability-only",

  "authority": "advisory",

  "overlay": {

    "overlayId": null,

    "overlayClassification": "mock-structure",

    "semanticIndicators": [],

    "semanticAnnotations": [],

    "inspectionSignals": []

  }

}

```

## Allowed Overlay Concepts

The mock overlay structure may describe:

- semantic section boundaries

- semantic inspection markers

- advisory semantic annotations

- chronology indicators

- semantic comparison indicators

## Explicit Overlay Restrictions

The overlay structures may not:

- render visually

- alter Preview composition

- mutate renderer output

- mutate runtime behavior

- mutate persistence behavior

- alter orchestration behavior

- alter retry behavior

- introduce semantic interaction authority

## Deterministic Overlay Rules

1. Overlay serialization ordering must remain stable.

2. Semantic indicator ordering must remain deterministic.

3. Null overlay fields must remain `null`.

4. Overlay definitions must remain reproducible across repeated inspections.

5. Overlay structures must remain removable without runtime impact.

## Validation Requirements

- deterministic overlay serialization

- assertion-compatible output

- rollback-safe removability

- DR-safe reconstruction

- Preview isolation preservation

## Explicit Non-Authority Statement

This overlay specification is not a rendering engine.

This overlay specification is not a Preview integration layer.

This overlay specification is not an interactive semantic UI system.

This overlay specification is observational-only.

