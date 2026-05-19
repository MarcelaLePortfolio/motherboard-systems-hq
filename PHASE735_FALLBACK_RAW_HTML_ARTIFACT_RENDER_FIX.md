
# Phase 735 Fallback Raw HTML Artifact Render Fix

## Finding

Browser DOM evidence showed the active preview used:

- `data-phase733-single-artifact-render-fallback="true"`

The fallback contained escaped raw Artifact Garden HTML.

That means marker extraction failed, but the artifact body itself was already HTML.

## Change

The fallback branch now detects decoded raw HTML artifacts and routes them through the same template mount + sanitized DOM render path.

## Boundary

Renderer-only deterministic fallback handling.

Sanitizer remains active.

No worker mutation.

No generator mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

