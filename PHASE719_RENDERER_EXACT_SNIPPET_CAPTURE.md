
# PHASE 719 — EXACT RENDERER SNIPPET CAPTURE

## PURPOSE

Capture the exact current implementation of the Phase 719 artifact preview corridor before any frontend-only mutation.

## CURRENT AUTHORITATIVE HEAD

`480dd212`

## TARGET FILE

`public/js/phase530_visible_panels_bridge.js`

## CAPTURE RANGE

The renderer corridor identified during inspection is approximately:

- 701–763: preview modal shell

- 769: preview HTML escaping

- 851–887: rendered artifact visual card

- 901–947: iframe/srcdoc wrapper

- 953–957: markdown adapter

- 963–1055: artifact preview fetch/open flow

- 1088: preview click listener

## RULE

This capture is read-only.

No implementation mutation occurs in this step.

