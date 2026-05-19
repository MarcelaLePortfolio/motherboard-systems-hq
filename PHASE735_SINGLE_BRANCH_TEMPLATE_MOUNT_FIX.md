
# Phase 735 Single-Branch Template Mount Fix

## Finding

Branch inspection showed that the active single-container preview branch still used the old data-attribute mount:

- `data-phase735-visual-html="${encodeURIComponent(safeVisualHtml)}"`

But the modal post-render callback had already been changed to expect:

- `data-phase735-visual-html-template`

## Change

The single-container branch now uses the same inert template mount contract as the post-render callback.

## Boundary

Renderer-only deterministic branch-contract alignment.

No worker mutation.

No generator mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

