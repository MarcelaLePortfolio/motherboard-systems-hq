
# Phase 723 Renderer Findings

## Authoritative Renderer

Confirmed authoritative renderer file:

`public/js/phase530_visible_panels_bridge.js`

This file is the active production rendering corridor for artifact preview rendering.

## Confirmed Preview Flow

Confirmed flow:

1. Preview button click

2. `phase719OpenPreviewModal(button)`

3. fetch:

   `/api/tasks/:task_id/artifact-preview`

4. response payload:

   `data.content`

5. render path:

   `phase719RenderMarkdownArtifactPreview(data.content)`

6. semantic renderer:

   `phase719RenderArtifactVisualCard(markdown)`

7. final injection:

   `body.innerHTML = phase719RenderMarkdownArtifactPreview(data.content)`

## Confirmed Semantic Rendering Model

Current rendering architecture is:

- markdown artifact persisted by worker

- semantic envelope extracted frontend-side

- markdown parsed frontend-side

- semantic cards generated frontend-side

- HTML generated frontend-side

- final preview injected through `innerHTML`

## Confirmed Safety Characteristics

Confirmed preserved characteristics:

- frontend-only rendering corridor

- read-only preview route

- markdown fallback preserved

- semantic rendering isolated from worker contracts

- retry contracts untouched

- SSE contracts untouched

- DB schema untouched

## Confirmed Existing Utilities

Confirmed utility functions:

- `phase720ExtractSemanticEnvelope(markdown)`

- `phase720StripSemanticEnvelope(markdown)`

- `phase719ExtractArtifactSections(markdown)`

- `phase719RenderArtifactVisualCard(markdown)`

- `phase719EscapePreviewHtml(value)`

## Confirmed iframe/srcdoc Status

Confirmed:

- iframe/srcdoc renderer exists only in quarantined backup:

  `phase530_visible_panels_bridge.js.phase719_iframe_v2_backup`

- live runtime currently does NOT use iframe rendering

- quarantined helper preserved for historical reference only

## Confirmed Sanitization State

Current findings:

- no DOMPurify detected

- no sanitize-html detected

- no dedicated sanitization library detected

Current renderer primarily relies on:

`phase719EscapePreviewHtml(value)`

This means all future embedded visual rendering must remain tightly bounded and explicitly sanitized.

## Confirmed Safe Insertion Boundary

Safest insertion boundary identified:

Inside:

`phase719RenderMarkdownArtifactPreview(markdown)`

Potential future strategy:

1. detect visual artifact markers

2. isolate embedded visual block

3. sanitize allowed subset

4. render visual block

5. preserve markdown fallback underneath

## Confirmed Rollback-Sensitive Areas

High-risk rollback-sensitive zones:

- `body.innerHTML`

- semantic extraction ordering

- markdown fallback rendering

- Preview modal lifecycle

- polling-triggered rerenders

- Agent Pool refresh persistence

## Current Recommendation

Next safe step:

Implement a NON-ACTIVE visual block extraction helper only.

No live rendering mutation yet.

The helper should:

- detect marker boundaries

- return extracted visual block

- return remaining markdown

- remain unused until browser validation stage

## Current Corridor Status

Renderer discovery complete.

Safe insertion boundary identified.

Sanitization gap identified.

No runtime mutation performed yet.

