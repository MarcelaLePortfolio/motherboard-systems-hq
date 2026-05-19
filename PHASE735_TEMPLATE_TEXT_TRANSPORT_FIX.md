
# Phase 735 Template Text Transport Fix

## Evidence

DOM validation showed the template/mount path is active, but HTML styles are corrupted before mount:

- first styled node has `style="\\"`

- style declarations become invalid attributes

## Finding

The browser was parsing template HTML before the decoder ran.

## Change

Template transport now stores sanitized artifact HTML as escaped text, and the mount callback reads `template.textContent` before decoding/sanitizing/mounting.

## Boundary

Renderer transport fix only.

No worker mutation.

No generator mutation.

No route mutation.

No database mutation.

No execution bridge activation.

No Matilda execution authority.

