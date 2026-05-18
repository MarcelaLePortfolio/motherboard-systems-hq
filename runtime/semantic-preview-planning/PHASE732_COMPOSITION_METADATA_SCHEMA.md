
# Phase 732 Composition Metadata Schema

## Status

Initial observability-only semantic composition metadata schema defined.

This schema is advisory and inspection-oriented only.

It grants no renderer authority, orchestration authority, Preview authority, execution authority, persistence authority, or runtime mutation capability.

## Schema Intent

The schema exists to support:

- semantic inspection

- preview composition observability

- developer diagnostics

- semantic density analysis

- readability analysis

- composition experimentation under containment discipline

The schema does not control rendering behavior.

## Proposed Metadata Object

```json

{

  "composition_metadata": {

    "recommended_section_order": [],

    "semantic_focus_zones": [],

    "preview_attention_weight": {},

    "composition_hints": [],

    "semantic_density": {},

    "section_readability_risk": {},

    "semantic_cohesion_score": {},

    "semantic_drift_score": {},

    "semantic_repetition_index": {},

    "preview_overload_risk": {}

  }

}

```

## Field Definitions

### recommended_section_order

Type:

- array

Purpose:

- Suggests observational ordering hypotheses for developer inspection.

Restrictions:

- Cannot mutate renderer order.

- Cannot affect Preview ordering.

- Cannot alter persisted artifact structure.

### semantic_focus_zones

Type:

- array

Purpose:

- Identifies semantically dense or important regions for inspection overlays.

Restrictions:

- Read-only.

- Advisory only.

### preview_attention_weight

Type:

- object

Purpose:

- Represents relative semantic concentration estimates.

Restrictions:

- No layout authority.

- No rendering influence.

### composition_hints

Type:

- array

Purpose:

- Human-readable semantic composition observations.

Examples:

- "High semantic clustering near conclusion"

- "Section density imbalance detected"

Restrictions:

- Cannot mutate UI or Preview structure.

### semantic_density

Type:

- object

Purpose:

- Measures semantic saturation by section.

Restrictions:

- Observability-only.

### section_readability_risk

Type:

- object

Purpose:

- Estimates readability degradation risk.

Restrictions:

- Diagnostic only.

### semantic_cohesion_score

Type:

- object

Purpose:

- Measures semantic continuity across sections.

Restrictions:

- No orchestration influence.

### semantic_drift_score

Type:

- object

Purpose:

- Estimates divergence between adjacent semantic regions.

Restrictions:

- Cannot influence retries, execution, or routing.

### semantic_repetition_index

Type:

- object

Purpose:

- Detects semantic duplication or repetition patterns.

Restrictions:

- Observability-only.

### preview_overload_risk

Type:

- object

Purpose:

- Estimates regions likely to overload Preview readability.

Restrictions:

- No Preview authority.

- No rendering mutation.

## Containment Guarantees

This schema must remain:

- additive

- optional

- reversible

- non-authoritative

- renderer-contained

- markdown-fallback-safe

- runtime-isolated

- Preview-isolated

- persistence-safe

## Explicit Non-Authority Guarantees

This schema may never:

- drive renderer logic

- alter component layout

- affect orchestration

- affect retries

- affect execution paths

- affect task routing

- alter persistence contracts

- override markdown rendering

- mutate Preview behavior

- become execution policy input

## Success Condition

The schema succeeds if:

- semantic composition signals become inspectable,

- Preview observability becomes richer,

- no runtime behavior changes occur,

- containment guarantees remain intact.

