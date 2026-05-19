
# Phase 733 Worker Style Intent Enrichment

## Change

Added producer-side semantic enrichment for explicit `style_intent:` blocks in delegated task text.

## Behavior

If a task request contains a style_intent block, the worker now promotes allowed keys into the `MB_SEMANTIC_ARTIFACT_V1` JSON envelope.

## Allowed Keys

- mood

- background

- card

- text

- secondary_text

- accent

- typography

- shadow

- density

## Scope

Worker artifact semantic envelope only.

## Safety Boundary

No execution bridge activation.

No route changes.

No database changes.

No persistence contract changes.

No artifact lifecycle authority change.

No Matilda execution authority.

## Expected Result

New artifact previews with explicit style_intent should activate the request-scoped preview renderer theme mapping.

