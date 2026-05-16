
# Phase 723 Renderer Inspection Plan

## Objective

Perform a zero-mutation inspection of the current artifact preview rendering stack before introducing any HTML-embedded visual artifact logic.

This phase is inspection-only.

No runtime contracts, backend routes, worker persistence, retry semantics, or DB structures may be modified during this inspection cycle.

## Inspection Targets

Primary renderer inspection targets:

1. `public/js/phase530_visible_panels_bridge.js`

2. Preview modal rendering pipeline

3. Semantic section extraction logic

4. Markdown fallback rendering path

5. Artifact preview fetch handling

6. Any existing sanitization utilities

7. Any remaining iframe/srcdoc helper remnants

8. Modal content injection boundaries

## Inspection Goals

Determine:

- where semantic rendering currently enters the Preview modal

- where markdown becomes HTML

- whether rendering currently uses:

  - `innerHTML`

  - DOMParser

  - markdown-it

  - marked

  - sanitize-html

  - DOMPurify

  - custom parsing

- whether visual block extraction can be safely isolated

- whether markdown fallback can remain untouched

- whether duplicate rendering risk exists

- whether Preview modal already has safe containment wrappers

## Required Preservation

The following must remain unchanged during inspection:

- Preview modal behavior

- Artifact route behavior

- SSE behavior

- Polling behavior

- Retry controls

- Task lifecycle rendering

- Semantic chip rendering

- Markdown fallback rendering

- Agent Pool refresh persistence

- Recent Tasks rendering stability

## Expected Deliverable

Inspection findings should produce:

1. authoritative renderer entry point

2. safest insertion boundary

3. safest sanitization strategy

4. fallback preservation strategy

5. visual block detection strategy

6. rollback boundary identification

## Strict Phase 723 Constraints

Forbidden during inspection:

- renderer rewrites

- backend mutations

- artifact schema mutations

- worker mutations

- retry mutations

- SSE mutations

- iframe/srcdoc reactivation

- dual-render layering experiments

- broad CSS experiments

## Recommended Inspection Commands

grep -R "artifact-preview" public server src

grep -R "innerHTML" public/js

grep -R "Preview" public/js

grep -R "markdown" public/js

grep -R "DOMPurify" .

grep -R "sanitize" .

grep -R "iframe" public/js

grep -R "srcdoc" public/js

## Validation Boundary

Inspection phase completes only after:

- authoritative renderer file confirmed

- Preview injection point confirmed

- fallback preservation path confirmed

- sanitization approach identified

- rollback boundary documented

## Current Status

Phase 723 inspection corridor now active.

No renderer mutation authorized yet.

