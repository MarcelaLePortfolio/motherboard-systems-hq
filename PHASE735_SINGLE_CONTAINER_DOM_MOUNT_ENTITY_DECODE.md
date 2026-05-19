
# Phase 735 Single-Container DOM Mount + Entity Decode

## Finding

The Artifact Garden preview still displayed raw `div style` HTML, meaning the single-container preview branch was still allowing escaped/encoded artifact HTML to surface as text.

## Change

The single-container branch now:

- decodes transport escapes

- decodes HTML entities through a textarea boundary

- sanitizes the resulting artifact HTML

- mounts sanitized artifact HTML after modal render using `innerHTML`

## Boundary

Renderer-only.

Sanitizer remains active.

No worker mutation.

No generator mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

