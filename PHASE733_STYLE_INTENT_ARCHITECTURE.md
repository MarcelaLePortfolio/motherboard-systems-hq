
# Phase 733 Style Intent Architecture

## Current State

Preview rendering is now:

- stable

- read-only

- semantically grouped

- transport-normalized

However:

- aesthetic intent is not yet interpreted into visual composition

- explicit styling instructions are still treated as plain content

## Correct Architectural Direction

Do not embed aesthetic presets directly into renderer defaults.

Instead:

- establish a neutral style-intent interpretation layer

- allow previews to opt into appearance changes only when style intent is explicitly present

## Required Properties

Style intent must be:

- request-scoped

- reversible

- non-authoritative

- preview-only

- additive

- renderer-safe

- execution-isolated

## Proposed Style Intent Contract

Example semantic envelope fragment:

{

  "style_intent": {

    "mood": "soft garden editorial",

    "background": "cream blush gradient",

    "card": "frosted floral glass",

    "text": "warm charcoal",

    "accent": "sage green",

    "typography": "elegant serif",

    "shadow": "soft diffuse",

    "density": "airy"

  }

}

## Rendering Model

Renderer should:

1. detect style_intent

2. normalize intent values

3. map intent to bounded visual tokens

4. apply tokens only inside preview container

5. preserve existing fallback renderer when absent

## Important Boundary

Renderer remains:

- preview-only

- non-executing

- non-persistent

- non-authoritative

No execution bridge activation.

No orchestration mutation.

No database mutation.

No lifecycle authority mutation.

No Matilda execution authority.

## Next Correct Corridor

Build a tiny bounded token mapper:

- not freeform CSS

- not arbitrary HTML

- not executable styling

Instead:

- curated semantic visual tokens

- safe renderer-scoped presentation mapping

- deterministic preview synthesis

## Long-Term Relevance

This corridor is foundational for:

- semantic-to-visual composition

- Matilda artifact awareness

- eventual preview-to-artifact convergence

- future render-native artifact synthesis

without prematurely hard-coding presentation assumptions.

