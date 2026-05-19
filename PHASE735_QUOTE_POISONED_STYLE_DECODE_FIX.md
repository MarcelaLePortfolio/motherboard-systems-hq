
# Phase 735 Quote-Poisoned Style Decode Fix

## Evidence

Final DOM evidence showed the fallback artifact now mounts into DOM, but inline styles are malformed:

- `style="\\" font-family:"=""`

- style declarations become invalid split attributes

## Interpretation

The render path is now active and correct.

The remaining issue is transport quote poisoning before sanitization.

## Change

The decode helper now removes escaped quote artifacts that poison inline style attributes before sanitizer/mount.

## Boundary

Renderer decode cleanup only.

No worker mutation.

No generator mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

