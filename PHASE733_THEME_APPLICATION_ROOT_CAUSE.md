
# Phase 733 Theme Application Root Cause

## Confirmed State

The semantic renderer IS consuming `phase733Theme`.

Theme values are visibly wired into:

- card backgrounds

- borders

- body text

- accent text

- insight panels

## Confirmed Remaining Fault Domain

The remaining dominant dark styling comes from the outer preview shell wrappers.

Specifically:

- iframe body background

- outer preview container background

- inline preview wrapper background

- hard-coded operational shell colors

These still force:

- dark navy shell

- operational dashboard appearance

- blue operational framing

even when semantic card internals are themed correctly.

## Critical Lines

### iframe shell

Lines 1256-1258:

html,body background:

#020617

### inline preview wrapper

Lines 1468-1470:

background:

rgba(15,23,42,.34)

border:

rgba(96,165,250,.22)

## Correct Next Corridor

Apply style-intent-aware theming to:

- outer preview shell

- iframe body

- inline preview wrapper

using the existing `phase733Theme` object.

## Scope

Renderer shell styling only.

No execution bridge activation.

No route mutation.

No database mutation.

No persistence contract mutation.

No artifact lifecycle authority change.

No Matilda execution authority.

